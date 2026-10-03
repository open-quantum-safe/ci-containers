#!/usr/bin/env bash
#
# Queries images.yml so that everything needing the image set asks one place:
# the build and publish matrices, the linting and the version check.
#
# shellcheck disable=SC2016  # the $names in the jq programs below are jq's, not the shell's

set -euo pipefail

IMAGES_FILE=images.yml

usage() {
  cat >&2 <<'EOF'
Usage:
  list-images.sh --dirs        directories holding the images' Dockerfiles
  list-images.sh --matrix      Actions matrix: one entry per image and architecture
  list-images.sh --multiarch   Actions matrix of the images published as a manifest
  list-images.sh --check       check images.yml against the repository layout
EOF
  exit 2
}

# yq reads the YAML, jq does the work; both are preinstalled on the runners.
query() { yq -o=json "$IMAGES_FILE" | jq "$@"; }

# An empty matrix is skipped without complaint: a green run that built nothing.
[ "$(query '.images | length')" -gt 0 ] ||
  { echo "::error file=$IMAGES_FILE::no images are listed." >&2; exit 1; }

case "${1:-}" in
  --dirs)
    query -r '.images[].dir'
    ;;

  --matrix)
    query -c '
      [ .images[] as $i
        | ($i.arches | length > 1) as $multiarch
        | $i.arches[]
        | { context: $i.dir,
            image:   $i.image,
            arch:    .,
            tag:     (if $multiarch then "latest-\(.)" else "latest" end),
            # Erroring beats defaulting a new arch onto an x86 runner.
            runner:  (if . == "arm64" then "ubuntu-24.04-arm"
                      elif . == "amd64" or . == "x86_64" then "ubuntu-latest"
                      else error("unknown architecture \(.); add a runner for it in list-images.sh") end) }
      ] | {include: .}'
    ;;

  --multiarch)
    query -c '
      [ .images[]
        | select(.arches | length > 1)
        | { image: .image, tags: ([.arches[] | "latest-\(.)"] | join(" ")) }
      ] | {include: .}'
    ;;

  --check)
    errors=0
    while IFS= read -r dir; do
      [ -f "$dir/Dockerfile" ] || {
        echo "::error file=$IMAGES_FILE::'$dir' is listed but holds no Dockerfile."
        errors=$((errors + 1))
      }
    done < <(query -r '.images[].dir')

    # An unlisted directory is silently never built, so name them. The
    # retired images are expected to be among them.
    unlisted=""
    for dir in */; do
      dir=${dir%/}
      [ -f "$dir/Dockerfile" ] || continue
      query -r '.images[].dir' | grep -qx "$dir" || unlisted="$unlisted $dir"
    done
    [ -z "$unlisted" ] ||
      echo "::notice file=$IMAGES_FILE::Not built, having no entry in $IMAGES_FILE:$unlisted"

    [ "$errors" -eq 0 ] || exit 1
    echo "$IMAGES_FILE matches the repository layout."
    ;;

  *)
    usage
    ;;
esac
