#!/usr/bin/env bash
#
# Check the `LABEL version` of every image CI publishes, before anything is
# built or pushed.
#
# Each push to main republishes `:latest`, so that label is the only signal a
# consumer has that the image behind the tag has changed. This checks that:
#
#   * every image carries a `LABEL version` in the expected format (a plain
#     incrementing integer, e.g. version="4");
#   * an image whose build context changed since BASE_REF has had its version
#     bumped past the one already released — republishing under a released
#     version silently changes what consumers get; and
#   * the label sits in the final build stage, so the published image actually
#     carries it (a warning: ubuntu-latest currently does not).
#
# BASE_REF is the commit the change is measured against: the pull request base
# on a PR, the previous commit otherwise. Needs full history (fetch-depth: 0).

set -euo pipefail

# The image set comes from images.yml, via the one script that reads it.
IMAGES=()
while IFS= read -r dir; do
  IMAGES+=("$dir")
done < <("$(dirname "$0")/list-images.sh" --dirs)

errors=0
fail() { echo "::error file=$1::$2"; errors=$((errors + 1)); }
warn() { echo "::warning file=$1::$2"; }

# version_of reads the first `LABEL version="N"` from a Dockerfile on stdin.
# `sed -n 1s` rather than `head -1` so nothing closes the pipe early and trips
# pipefail on an otherwise-passing file.
version_of() {
  grep -iE '^[[:space:]]*LABEL[[:space:]]+version=' |
    sed -nE '1s/.*[Vv]ersion="?([^"[:space:]]+)"?.*/\1/p'
}

is_version() { printf '%s' "$1" | grep -qE '^[1-9][0-9]*$'; }

# Compare against the merge base, so commits landed on main since this branch
# was cut are not mistaken for the branch lowering a version.
base=""
if [ -n "${BASE_REF:-}" ] && git rev-parse -q --verify "${BASE_REF}^{commit}" >/dev/null; then
  base=$(git merge-base "$BASE_REF" HEAD 2>/dev/null || printf '%s' "$BASE_REF")
else
  base=$(git rev-parse -q --verify 'HEAD^{commit}' || true)
fi
if [ -z "$base" ]; then
  echo "No base commit available; checking the version format only."
fi

for dir in "${IMAGES[@]}"; do
  file="$dir/Dockerfile"

  if [ ! -f "$file" ]; then
    fail "$file" "$dir is published by CI but has no Dockerfile."
    continue
  fi

  version=$(version_of <"$file" || true)
  if [ -z "$version" ]; then
    fail "$file" "no 'LABEL version=' found; every published image must carry one."
    continue
  fi
  if ! is_version "$version"; then
    fail "$file" "version '$version' is not a plain incrementing integer, e.g. version=\"4\"."
    continue
  fi

  # A label in an earlier stage is dropped from the published image, whatever
  # the Dockerfile appears to say.
  last_from=$(grep -niE '^[[:space:]]*FROM[[:space:]]' "$file" | tail -n1 | cut -d: -f1)
  label_line=$(grep -niE '^[[:space:]]*LABEL[[:space:]]+version=' "$file" |
                 sed -n 1p | cut -d: -f1)
  if [ "$label_line" -lt "$last_from" ]; then
    warn "$file" "'LABEL version' on line $label_line belongs to a build stage before the final FROM on line $last_from, so the published image does not carry it."
  fi

  [ -n "$base" ] || continue

  if git diff --quiet "$base" HEAD -- "$dir"; then
    echo "$dir: version $version, build context unchanged since ${base:0:12}."
    continue
  fi

  released=$(git show "$base:$file" 2>/dev/null | version_of || true)
  if [ -z "$released" ]; then
    echo "$dir: version $version, new image."
    continue
  fi
  if ! is_version "$released"; then
    warn "$file" "released version '$released' at ${base:0:12} is not an integer; skipping the comparison."
    continue
  fi

  if [ "$version" -eq "$released" ]; then
    fail "$file" "$dir has changed but 'LABEL version' is still $version, which is already released. Bump it to $((released + 1))."
  elif [ "$version" -lt "$released" ]; then
    fail "$file" "$dir 'LABEL version' is $version, lower than the released $released."
  else
    echo "$dir: version $released -> $version."
  fi
done

if [ "$errors" -ne 0 ]; then
  echo "Image version check failed with $errors error(s)."
  exit 1
fi

echo "Image versions are consistent."
