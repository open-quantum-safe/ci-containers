ARG ARCH
FROM ${ARCH}/centos:8
LABEL version="2"

RUN yum -y update && \
    yum -y install \
        yum-utils \
        gcc \
        cmake \
        autoconf automake git openssl-devel libtool make \
        python3-pip && \
    yum check-update && \
    pip3 install -U nose rednose pytest pytest-xdist

RUN dnf config-manager --set-enabled PowerTools && \
    dnf -y install \
           doxygen \
           doxygen-latex \
           doxygen-doxywizard \
           ninja-build

# Install docker for CCI docker image generation
RUN dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo && dnf install docker-ce --nobest -y

