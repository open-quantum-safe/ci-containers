#!/usr/bin/env bash
#
# Validate subscribers.yml so a contributor's PR gets fast, clear feedback.
# Checks that the file parses, that every entry has a well-formed `repo` and a
# non-empty `images` list, and that each watched image is one CI publishes.

set -euo pipefail

SUBSCRIBERS_FILE=subscribers.yml

# Keep in sync with .github/scripts/notify-subscribers.sh and push.yml.
KNOWN_IMAGES=(ci-ubuntu-focal ci-ubuntu-jammy ci-ubuntu-latest ci-alpine-amd64)

fail() { echo "::error file=$SUBSCRIBERS_FILE::$1"; errors=$((errors + 1)); }

errors=0

if ! yq e '.' "$SUBSCRIBERS_FILE" >/dev/null 2>&1; then
  echo "::error file=$SUBSCRIBERS_FILE::File is not valid YAML."
  exit 1
fi

if [ "$(yq e '.subscribers | tag' "$SUBSCRIBERS_FILE")" != "!!seq" ]; then
  echo "::error file=$SUBSCRIBERS_FILE::Top-level 'subscribers' must be a list."
  exit 1
fi

count=$(yq e '.subscribers | length' "$SUBSCRIBERS_FILE")
if [ "$count" -eq 0 ]; then
  echo "No subscribers defined; nothing to validate."
  exit 0
fi

for ((i = 0; i < count; i++)); do
  repo=$(yq e ".subscribers[$i].repo // \"\"" "$SUBSCRIBERS_FILE")
  # Subscriptions are limited to the open-quantum-safe organization (see README).
  if ! printf '%s' "$repo" | grep -qE '^open-quantum-safe/[A-Za-z0-9_.-]+$'; then
    fail "subscribers[$i].repo ('$repo') must be an open-quantum-safe repository, e.g. open-quantum-safe/oqs-provider."
    continue
  fi

  images_tag=$(yq e ".subscribers[$i].images | tag" "$SUBSCRIBERS_FILE")
  if [ "$images_tag" != "!!seq" ]; then
    fail "subscribers[$i] ($repo): 'images' must be a non-empty list."
    continue
  fi

  n_images=$(yq e ".subscribers[$i].images | length" "$SUBSCRIBERS_FILE")
  if [ "$n_images" -eq 0 ]; then
    fail "subscribers[$i] ($repo): 'images' must not be empty."
    continue
  fi

  while IFS= read -r img; do
    known=0
    for k in "${KNOWN_IMAGES[@]}"; do
      [ "$k" = "$img" ] && { known=1; break; }
    done
    if [ "$known" -eq 0 ]; then
      fail "subscribers[$i] ($repo): unknown image '$img'. Known images: ${KNOWN_IMAGES[*]}"
    fi
  done < <(yq e ".subscribers[$i].images[]" "$SUBSCRIBERS_FILE")
done

if [ "$errors" -ne 0 ]; then
  echo "subscribers.yml validation failed with $errors error(s)."
  exit 1
fi

echo "subscribers.yml is valid ($count subscriber(s))."
