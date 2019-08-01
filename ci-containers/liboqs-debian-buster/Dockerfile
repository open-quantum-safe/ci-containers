ARG ARCH
FROM multiarch/debian-debootstrap:${ARCH}-buster

RUN apt-get update -qq
RUN apt-get upgrade -y
RUN apt-get dist-upgrade -y
RUN apt-get install -y gcc gcc-4.9 gcc-7 gcc-8
RUN apt-get install -y autoconf automake git libssl-dev libtool make unzip wget zlib1g-dev
RUN apt-get install -y doxygen graphviz xsltproc
RUN apt-get install -y python3 python3-nose python3-rednose python3-pytest python3-pytest-xdist
