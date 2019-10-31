#!/bin/bash

cd liboqs-debian-buster && docker build --build-arg ARCH=amd64 -t liboqs-debian-buster .
cd ..
cd liboqs-ubuntu-bionic && docker build --build-arg ARCH=x86_64 -t liboqs-ubuntu-bionic .
cd ..
cd liboqs-centos-7 && docker build -t liboqs-centos-7 .
echo "Logging to to dockerhub as openqsafe"
docker login -u openqsafe 
docker tag liboqs-debian-buster openqsafe/liboqs-debian-buster && docker push openqsafe/liboqs-debian-buster
docker tag liboqs-ubuntu-bionic openqsafe/liboqs-ubuntu-bionic && docker push openqsafe/liboqs-ubuntu-bionic
docker tag liboqs-centos-7 openqsafe/liboqs-centos-7 && docker push openqsafe/liboqs-centos-7

