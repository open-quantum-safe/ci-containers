#!/bin/bash

cd liboqs-debian-buster && docker build --build-arg ARCH=amd64 -t liboqs-debian-buster .
cd ..
cd liboqs-ubuntu-bionic && docker build --build-arg ARCH=x86_64 -t liboqs-ubuntu-bionic .
echo "Logging to to dockerhub as openqsafe"
docker login -u openqsafe 
docker tag liboqs-debian-buster openqsafe/liboqs-debian-buster && docker push openqsafe/liboqs-debian-buster
docker tag liboqs-ubuntu-bionic openqsafe/liboqs-ubuntu-bionic && docker push openqsafe/liboqs-ubuntu-bionic

