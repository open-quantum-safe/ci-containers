#!/bin/bash

BASENAME=ubuntu-bionic
LOCALIMAGENAME=liboqs-$BASENAME
ARCH=x86_64

# This script is to simplify building and publishing this image and follow a standard naming convention

docker build -t $LOCALIMAGENAME --build-arg ARCH=$ARCH .

if [ $# -gt 0 ]; then
   echo "Pushing image to openqsafe. Be sure to be logged in, eg via 'docker login -u openqsafe'"
   docker tag $LOCALIMAGENAME openqsafe/ci-$BASENAME && docker push openqsafe/ci-$BASENAME
fi


