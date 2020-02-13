#!/bin/sh
# Push a specified image to Docker Hub.
# For ARM based images, be sure to first run
# docker run --rm --privileged \
#            multiarch/qemu-user-static:register
#            --reset
# To push images to openquantumsafe, ensure
# you are logged in.
set -eux

if [ "$#" -ne 2 ]; then
    printf "Usage: ./push-img <dirname> <arch>
<dirname>: name of a directory in this repository.
<arch>: desired architecture of Docker image."
    exit
fi

BASENAME=$1
ARCH=$2

IMAGENAME=ci-"${BASENAME}"-"${ARCH}"

cd "${BASENAME}"

docker build --build-arg ARCH="${ARCH}" -t "${IMAGENAME}":staging .
VERSION=$(docker inspect \
              --format "{{ index .Config.Labels \"version\"}}" \
              "${IMAGENAME}":staging)

docker tag "${IMAGENAME}":staging openquantumsafe/"${IMAGENAME}":"${VERSION}"
docker push openquantumsafe/"${IMAGENAME}":"${VERSION}"

docker tag openquantumsafe/"${IMAGENAME}":"${VERSION}" openquantumsafe/"${IMAGENAME}":latest
docker push openquantumsafe/"${IMAGENAME}":latest
