#!/usr/bin/env bash
#
# Queries images.yml, the list of images this repository publishes, so that
# everything needing to know the image set asks one place: the build and publish
# matrices, the Dockerfile linting and the LABEL version check.
#
# Usage:
#   list-images.sh --dirs        directories holding the images' Dockerfiles
#   list-images.sh --matrix      Actions matrix: one entry per image and architecture
#   list-images.sh --multiarch   Actions matrix of the images published as a manifest
#   list-images.sh --check       check images.yml against the repository layout
#
# shellcheck disable=SC2016  # the $names in the jq programs below are jq's, not the shell's

set -euo pipefail

IMAGES_FILE=images.yml

# yq reads the YAML, jq does the work: both are preinstalled on the runners.
query() { yq -o=json "$IMAGES_FILE" | jq "$@"; }

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
            runner:  (if . == "arm64" then "ubuntu-24.04-arm" else "ubuntu-latest" end) }
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

    # A new image directory that nobody added to images.yml is silently never
    # built, so name the unlisted ones rather than leaving that to be noticed
    # later. The retired images are expected to be among them.
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
    sed -n '3,11p' "$0" | sed 's/^# \{0,1\}//' >&2
    exit 2
    ;;
esac
