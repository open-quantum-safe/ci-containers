ARG ARCH
FROM multiarch/ubuntu-core:${ARCH}-bionic
LABEL version="6"

RUN apt-get update -qq && \
    apt-get dist-upgrade -y && \
    apt-get install -y autoconf \
                       automake \
                       astyle \
                       clang-9 \
                       cmake \
                       docker.io \
                       doxygen \
                       gcc gcc-7 gcc-8\
                       g++ \
                       git \
                       golang-go \
                       libtool \
                       libssl-dev \
                       libunwind-dev \
                       make \
                       ninja-build \
                       python3 \
                       python3-nose \
                       python3-rednose \
                       python3-pytest \
                       python3-pytest-xdist \
                       python3-psutil \
                       zlib1g-dev
