ARG ARCH
FROM multiarch/ubuntu-core:${ARCH}-xenial

RUN apt-get update -qq
RUN apt-get install -y software-properties-common
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 1E9377A2BA9EF27F
RUN add-apt-repository -y ppa:ubuntu-toolchain-r/test
RUN apt-get update -qq
RUN apt-get upgrade -y
RUN apt-get dist-upgrade -y
RUN apt-get install -y gcc gcc-4.9 gcc-5 gcc-6 gcc-7 gcc-8
RUN apt-get install -y autoconf automake git libssl-dev libtool make unzip wget 
RUN apt-get install -y doxygen graphviz xsltproc 
RUN apt-get install -y python3 python3-nose python3-rednose python3-pytest
