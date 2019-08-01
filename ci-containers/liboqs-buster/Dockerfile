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
	zlib1g-dev \
	wget \
	xsltproc \
	doxygen \
	graphviz \
	python3 \
	python3-nose \
	python3-rednose \
	python3-pytest \
	python3-pytest-xdist