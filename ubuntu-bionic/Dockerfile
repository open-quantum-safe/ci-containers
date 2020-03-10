ARG ARCH
FROM multiarch/ubuntu-core:${ARCH}-bionic
LABEL version="5"

RUN apt-get update -qq
RUN apt-get upgrade -y
RUN apt-get dist-upgrade -y
RUN apt-get install -y gcc gcc-7 gcc-8
RUN apt-get install -y astyle
RUN apt-get install -y cmake ninja-build
RUN apt-get install -y autoconf automake git libssl-dev libtool make unzip wget zlib1g-dev
RUN apt-get install -y doxygen graphviz xsltproc
RUN apt-get install -y python3 python3-nose python3-rednose python3-pytest python3-pytest-xdist
RUN apt-get install -y clang-9 docker.io
