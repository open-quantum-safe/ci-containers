#!/usr/bin/env bash
#
# Notify subscribed downstream projects that a new version of an OQS CI
# container image has been published to Docker Hub.
#
# For each image whose `LABEL version` changed in the commit that was just
# built and pushed, this resolves the newly published multi-arch manifest
# digest and opens a GitHub issue on every repository that subscribes to that
# image in subscribers.yml.
#
# Required environment:
#   GH_TOKEN      A token with `issues:write` on the subscriber repositories
#                 (supplied from the NOTIFY_TOKEN secret). If unset, the script
#                 exits early without notifying.
#   SOURCE_REPO   owner/repo of this ci-containers repository (github.repository).
#   SOURCE_SHA    The commit that was built (used for provenance links).
#
# Optional (for manual workflow_dispatch runs):
#   FORCE_IMAGE   Announce this image regardless of the version diff.
#   FORCE_VERSION Version string to announce (defaults to the Dockerfile label).

set -euo pipefail

ORG=openquantumsafe
SUBSCRIBERS_FILE=subscribers.yml

# Container directory -> Docker Hub image repo (under openquantumsafe/).
# Only images that CI actually publishes belong here; keep this in sync with
# .github/workflows/push.yml.
declare -A IMAGES=(
  [ubuntu-focal]=ci-ubuntu-focal
  [ubuntu-jammy]=ci-ubuntu-jammy
  [ubuntu-latest]=ci-ubuntu-latest
  [alpine]=ci-alpine-amd64
)

if [ -z "${GH_TOKEN:-}" ]; then
  echo "NOTIFY_TOKEN is not configured; skipping subscriber notifications." >&2
  exit 0
fi

# Extract the value of `LABEL version="..."` from a Dockerfile.
version_of() {
  grep -iE 'LABEL[[:space:]]+version=' "$1" | head -n1 \
    | sed -E 's/.*[Vv]ersion="?([^"[:space:]]+)"?.*/\1/'
}

# Determine which images to announce.
changed_dirs=()
if [ -n "${FORCE_IMAGE:-}" ]; then
  for dir in "${!IMAGES[@]}"; do
    [ "${IMAGES[$dir]}" = "$FORCE_IMAGE" ] && changed_dirs+=("$dir")
  done
  if [ ${#changed_dirs[@]} -eq 0 ]; then
    echo "FORCE_IMAGE='$FORCE_IMAGE' is not a known published image." >&2
    exit 1
  fi
else
  for dir in "${!IMAGES[@]}"; do
    df="$dir/Dockerfile"
    [ -f "$df" ] || continue
    # Did this commit change the LABEL version line for this image?
    if git diff HEAD^ HEAD -- "$df" \
         | grep -qiE '^\+[[:space:]]*LABEL[[:space:]]+version='; then
      changed_dirs+=("$dir")
    fi
  done
fi

if [ ${#changed_dirs[@]} -eq 0 ]; then
  echo "No container version bumps detected in $SOURCE_SHA; nothing to notify."
  exit 0
fi

subscriber_count=$(yq e '.subscribers | length' "$SUBSCRIBERS_FILE")

for dir in "${changed_dirs[@]}"; do
  image="${IMAGES[$dir]}"
  repo_image="$ORG/$image"
  version="${FORCE_VERSION:-$(version_of "$dir/Dockerfile")}"

  # Resolve the multi-arch manifest digest that consumers pin as `@sha256:...`.
  digest=$(docker buildx imagetools inspect "${repo_image}:latest" \
             --format '{{ .Manifest.Digest }}' 2>/dev/null || true)
  if [ -z "$digest" ]; then
    echo "::warning::Could not resolve digest for $repo_image:latest; skipping." >&2
    continue
  fi

  short_digest=${digest#sha256:}; short_digest=${short_digest:0:12}
  echo "Detected new version of $repo_image: version=$version digest=$digest"

  for ((i = 0; i < subscriber_count; i++)); do
    repo=$(yq e ".subscribers[$i].repo" "$SUBSCRIBERS_FILE")
    # Skip subscribers that do not watch this image.
    if ! yq e ".subscribers[$i].images[]" "$SUBSCRIBERS_FILE" \
           | grep -qx "$image"; then
      continue
    fi

    title="New $repo_image version $version available ($short_digest)"

    # Avoid opening a duplicate if this exact version was already announced.
    existing=$(gh issue list --repo "$repo" --state all \
                 --search "\"$title\" in:title" --json number --jq 'length' \
                 2>/dev/null || echo 0)
    if [ "${existing:-0}" != "0" ]; then
      echo "  $repo already has an issue for this version; skipping."
      continue
    fi

    mentions=$(yq e ".subscribers[$i].mention[]" "$SUBSCRIBERS_FILE" 2>/dev/null \
                 | sed 's/^/@/' | paste -sd', ' - || true)

    body_file=$(mktemp)
    {
      echo "A new version of the OQS CI container image **\`$repo_image\`** has been published to Docker Hub."
      echo
      echo "| | |"
      echo "|---|---|"
      echo "| Image | \`$repo_image\` |"
      echo "| New version | \`$version\` |"
      echo "| Digest | \`$digest\` |"
      echo "| Published from | [\`$SOURCE_REPO@${SOURCE_SHA:0:12}\`](https://github.com/$SOURCE_REPO/commit/$SOURCE_SHA) |"
      echo
      echo "### Pin this image by digest (recommended)"
      echo
      echo "Replace any \`:latest\` (or older-digest) reference in your workflows with the immutable digest:"
      echo
      echo '```yaml'
      echo "    container:"
      echo "      image: $repo_image@$digest"
      echo '```'
      echo
      echo "### Verify"
      echo
      echo "- Docker Hub tags: <https://hub.docker.com/r/$repo_image/tags>"
      echo "- Confirm the digest yourself:"
      echo
      echo '```console'
      echo "\$ docker buildx imagetools inspect ${repo_image}:latest --format '{{ .Manifest.Digest }}'"
      echo "$digest"
      echo '```'
      echo
      echo "Relying on \`:latest\` (a mutable tag) in CI is a security risk: the image behind it can change without notice. Pinning the digest above guarantees you build against exactly the image published here."
      echo
      echo "---"
      echo "_This issue was opened automatically by [$SOURCE_REPO](https://github.com/$SOURCE_REPO). To change or stop these notifications, edit your entry in [\`subscribers.yml\`](https://github.com/$SOURCE_REPO/blob/main/subscribers.yml)._"
      if [ -n "$mentions" ]; then echo; echo "cc $mentions"; fi
    } >"$body_file"

    if url=$(gh issue create --repo "$repo" --title "$title" --body-file "$body_file"); then
      echo "  Opened issue on $repo: $url"
    else
      echo "::warning::Failed to open issue on $repo (check NOTIFY_TOKEN access)." >&2
    fi
    rm -f "$body_file"
  done
done
