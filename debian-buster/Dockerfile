ARG ARCH
FROM multiarch/debian-debootstrap:${ARCH}-buster
LABEL version="2"

RUN apt-get update -qq
RUN apt-get upgrade -y
RUN apt-get dist-upgrade -y
RUN apt-get install -y gcc
RUN apt-get install -y cmake ninja-build
RUN apt-get install -y autoconf automake git libssl-dev libtool make unzip wget zlib1g-dev
RUN apt-get install -y doxygen graphviz xsltproc
RUN apt-get install -y python3 python3-nose python3-rednose python3-pytest python3-pytest-xdist docker.io
