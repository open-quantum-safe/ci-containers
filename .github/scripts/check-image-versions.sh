#!/usr/bin/env bash
#
# Checks each published image's `LABEL version` before anything is built: it
# exists in the final build stage (the only one the image carries), is a plain
# integer, and has been bumped past the released one when the build context
# changed. Republishing under a released version changes `:latest` unannounced.
#
# BASE_REF is what the change is measured against: the PR base, else HEAD^.
# Needs full history (fetch-depth: 0).

set -euo pipefail

# The image set comes from images.yml. A process substitution swallows the exit
# status, so an empty result would pass without checking anything.
IMAGES=()
while IFS= read -r dir; do
  IMAGES+=("$dir")
done < <("$(dirname "$0")/list-images.sh" --dirs)
if [ ${#IMAGES[@]} -eq 0 ]; then
  echo "::error::list-images.sh returned no images; nothing was checked."
  exit 1
fi

errors=0
fail() { echo "::error file=$1::$2"; errors=$((errors + 1)); }
warn() { echo "::warning file=$1::$2"; }

# The `LABEL version` of the final stage of the Dockerfile on stdin: each FROM
# starts a stage and discards the labels before it.
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

# The merge base, so commits landed on main since the branch was cut are not
# read as this branch lowering a version.
base=""
if [ -n "${BASE_REF:-}" ] && git rev-parse -q --verify "${BASE_REF}^{commit}" >/dev/null; then
  base=$(git merge-base "$BASE_REF" HEAD 2>/dev/null || printf '%s' "$BASE_REF")
else
  # 'HEAD^' is the parent; 'HEAD^{commit}' would just peel HEAD to itself.
  base=$(git rev-parse -q --verify 'HEAD^' || true)
fi
if [ -z "$base" ]; then
  echo "::warning::No base commit available (a shallow checkout?); checking the version format only."
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
