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
  if [ "$images_tag" != "!!seq" ] ||
     [ "$(yq e ".subscribers[$i].images | length" "$SUBSCRIBERS_FILE")" -eq 0 ]; then
    fail "subscribers[$i] ($repo): 'images' must be a non-empty list."
  else
    while IFS= read -r img; do
      known=0
      for k in "${KNOWN_IMAGES[@]}"; do
        [ "$k" = "$img" ] && { known=1; break; }
      done
      if [ "$known" -eq 0 ]; then
        fail "subscribers[$i] ($repo): unknown image '$img'. Known images: ${KNOWN_IMAGES[*]}"
      fi
    done < <(yq e ".subscribers[$i].images[]" "$SUBSCRIBERS_FILE")
  fi

  # 'mention' is optional, but when present each entry must be a bare GitHub
  # username (a maintainer from the subscribed repository's GOVERNANCE.md) or an
  # open-quantum-safe team, written 'open-quantum-safe/<team-slug>'. No leading
  # '@': notify-subscribers.sh adds it.
  mention_tag=$(yq e ".subscribers[$i].mention | tag" "$SUBSCRIBERS_FILE")
  if [ "$mention_tag" = "!!null" ]; then
    continue
  elif [ "$mention_tag" != "!!seq" ]; then
    fail "subscribers[$i] ($repo): 'mention' must be a list."
    continue
  fi

  while IFS= read -r who; do
    if ! printf '%s' "$who" |
         grep -qE '^([A-Za-z0-9]([A-Za-z0-9-]{0,37}[A-Za-z0-9])?|open-quantum-safe/[A-Za-z0-9._-]+)$'; then
      fail "subscribers[$i] ($repo): mention '$who' must be a GitHub username or an open-quantum-safe team (open-quantum-safe/<team-slug>), without a leading '@'."
    fi
  done < <(yq e ".subscribers[$i].mention[]" "$SUBSCRIBERS_FILE")
done

# Two entries for the same repository would open duplicate issues.
dupes=$(yq e '.subscribers[].repo' "$SUBSCRIBERS_FILE" | sort | uniq -d)
if [ -n "$dupes" ]; then
  fail "duplicate repo entries: $(printf '%s' "$dupes" | paste -sd' ' -)."
fi

if [ "$errors" -ne 0 ]; then
  echo "subscribers.yml validation failed with $errors error(s)."
  exit 1
fi

echo "subscribers.yml is valid ($count subscriber(s))."
