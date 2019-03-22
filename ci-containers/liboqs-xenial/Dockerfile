ARG ARCH
FROM multiarch/ubuntu-core:${ARCH}-xenial

RUN apt-get update -qq \
 && apt-get upgrade -y \
 && apt-get dist-upgrade -y \
 && apt-get install -y \
	autoconf \
	automake \
	gcc \
	git \
	libssl-dev \
	libtool \
	make \
	unzip \
	wget \
	xsltproc \
	doxygen \
	graphviz \
	python3 \
	python3-nose \
	python3-rednose