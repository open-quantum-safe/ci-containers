ARG ARCH
FROM ${ARCH}/centos:8
LABEL version="3"

RUN yum -y update && \
    yum -y install \
        yum-utils \
        gcc \
        cmake \
        autoconf automake git openssl-devel libtool make \
        python3-pip python3-devel wget && \
    yum check-update && \
    pip3 install -U nose rednose pytest pytest-xdist psutil

RUN dnf config-manager --set-enabled PowerTools && \
    dnf -y install \
           doxygen \
           doxygen-latex \
           doxygen-doxywizard \
           ninja-build

# Install docker for CCI docker image generation
RUN dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo && dnf install docker-ce --nobest -y

# go for BoringSSL testing:
#RUN wget https://dl.google.com/go/go1.13.4.linux-amd64.tar.gz && tar -xzf go1.13.4.linux-amd64.tar.gz && mv go /usr/local 
#
#env GOROOT=/usr/local/go
#env PATH=$GOPATH/bin:$GOROOT/bin:$PATH
