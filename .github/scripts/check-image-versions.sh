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
#   * that label sits in the image's final build stage, since only that stage
#     reaches the published image.
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

# version_of prints the `LABEL version` of the *final* build stage of the
# Dockerfile on stdin, which is the only one the published image carries: each
# FROM starts a new stage and discards the labels of the one before it.
version_of() {
  awk '
    tolower($1) == "from" { version = "" }
    tolower($1) == "label" && tolower($2) ~ /^version=/ {
      version = $2
      sub(/^[^=]*=/, "", version)
      gsub(/"/, "", version)
    }
    END { if (version != "") print version }
  '
}

is_version() { printf '%s' "$1" | grep -qE '^[1-9][0-9]*$'; }

# Compare against the merge base, so commits landed on main since this branch
# was cut are not mistaken for the branch lowering a version.
base=""
if [ -n "${BASE_REF:-}" ] && git rev-parse -q --verify "${BASE_REF}^{commit}" >/dev/null; then
  base=$(git merge-base "$BASE_REF" HEAD 2>/dev/null || printf '%s' "$BASE_REF")
else
  # The parent commit: 'HEAD^' is that, whereas 'HEAD^{commit}' would only peel
  # HEAD itself to a commit and compare it against itself.
  base=$(git rev-parse -q --verify 'HEAD^' || true)
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
    fail "$file" "no 'LABEL version=' in the final build stage, so the published image would not carry one. A label in an earlier stage does not reach it."
    continue
  fi
  if ! is_version "$version"; then
    fail "$file" "version '$version' is not a plain incrementing integer, e.g. version=\"4\"."
    continue
  fi

  [ -n "$base" ] || continue

  if git diff --quiet "$base" HEAD -- "$dir"; then
    echo "$dir: version $version, build context unchanged since ${base:0:12}."
    continue
  fi

  if ! git cat-file -e "$base:$file" 2>/dev/null; then
    echo "$dir: version $version, new image."
    continue
  fi

  released=$(git show "$base:$file" | version_of || true)
  if [ -z "$released" ]; then
    warn "$file" "the released Dockerfile at ${base:0:12} carries no 'LABEL version' in its final stage, so there is nothing to compare against."
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
