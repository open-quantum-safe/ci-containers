ARG ARCH
FROM ${ARCH}/centos:7
LABEL version="1"

RUN yum -y update && \
    yum -y install \
        gcc \
        git \
        autoconf \
        automake \
        libtool \
        perl-core \
        make \
        yum-utils \
        wget \
        doxygen \
        xsltproc \
        python3 \
        python3-pip && \
    yum check-update && \
    yum -y install centos-release-scl-rh yum-utils

RUN pip3 install -U ninja pytest nose rednose pytest-xdist

# Yum installs CMake 2.6, and liboqs
# needs at least CMake 3.0
WORKDIR /tmp
RUN wget https://github.com/Kitware/CMake/releases/download/v3.16.4/cmake-3.16.4-Linux-x86_64.sh && \
    mkdir /opt/cmake && \
    sh cmake-3.16.4-Linux-x86_64.sh --skip-license --prefix=/opt/cmake && \
    ln -s /opt/cmake/bin/cmake /usr/bin/cmake

# Upgrade to OpenSSL 1.1.1
ADD build-openssl111d.sh /root/build-openssl111d.sh
RUN /root/build-openssl111d.sh

# Install more current gcc for OQS building
RUN yum -y install centos-release-scl devtoolset-8-gcc* libtool && echo "source /opt/rh/devtoolset-8/enable" >> /root/.bashrc
