#!/bin/bash
# Push a specified image to
# Docker Hub.
set -eu

if [ "$#" -ne 1 ]; then
    printf "Usage: ./push-img <dirname>
where <dirname> is the name of a
directory in this repository."
    exit
fi

BASENAME=$1
IMAGENAME=ci-"${BASENAME}"

cd "${BASENAME}"

docker build -t "${IMAGENAME}"

printf "Pushing image to openqsafe."
#TODO: Confirm tagging strategy
docker tag "${IMAGENAME}" openquantumsafe/ci-"${IMAGENAME}":v1
docker push openquantumsafe/ci-"${BASENAME}":v1
