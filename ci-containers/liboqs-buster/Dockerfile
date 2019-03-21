ARG ARCH
FROM multiarch/debian-debootstrap:${ARCH}-buster

RUN apt-get update -qq \
 && apt-get upgrade -y \
 && apt-get dist-upgrade -y \
 && apt-get install -y autoconf \
	automake \
	libtool \
	gcc \
	git \
	libssl-dev \
	make \
	unzip \
	wget \
	xsltproc \
	doxygen \
	graphviz \
	python3 \
	python3-nose \
	python3-rednose