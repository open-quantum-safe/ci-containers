#!/bin/bash
# Push a specified image to
# the Docker Hub.
set -eu

if [ "$#" -ne 1 ]; then
    printf "Usage: ./push-img <dirname>
where <dirname> is the name of a
directory in this repository."
    exit
fi

BASENAME=$1
LOCALIMAGENAME=oqs-"${BASENAME}"

cd "${BASENAME}"

docker build -t "${LOCALIMAGENAME}"

printf "Pushing image to openqsafe."
docker tag "${LOCALIMAGENAME}" openquantumsafe/ci-"${BASENAME}"
docker push openquantumsafe/ci-"${BASENAME}"
