ARG ARCH
FROM multiarch/ubuntu-core:${ARCH}-trusty

RUN apt-get update -qq
RUN apt-get upgrade -y
RUN apt-get dist-upgrade -y
RUN apt-get install -y gcc-4.7 gcc-4.8
RUN apt-get install -y autoconf automake git libssl-dev libtool make unzip wget 
RUN apt-get install -y doxygen graphviz xsltproc 
RUN apt-get install -y python3 python3-nose python3-pytest
