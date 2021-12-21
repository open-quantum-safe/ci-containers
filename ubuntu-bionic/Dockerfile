ARG ARCH
FROM multiarch/ubuntu-core:${ARCH}-bionic
LABEL version="6"

RUN apt-get update -qq && \
    apt-get dist-upgrade -y && \
    apt-get install -y wget && \
    wget https://dl.google.com/go/go1.14.3.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.14.3.linux-amd64.tar.gz && \
    cp /usr/local/go/bin/* /usr/bin && \
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
                       libtool \
                       libssl-dev \
                       libunwind-dev \
                       make \
                       ninja-build \
                       pkg-config \
                       python3 \
                       python3-nose \
                       python3-rednose \
                       python3-pytest \
                       python3-pytest-xdist \
                       python3-psutil \
                       zlib1g-dev \
                       maven \
                       openjdk-11-jdk \
                       qemu \
                       libc6-dbg

RUN if [ X"${ARCH}" != X"i386" ] ; then cd /tmp && wget https://sourceware.org/pub/valgrind/valgrind-3.16.1.tar.bz2 && tar -xf valgrind-3.16.1.tar.bz2 && cd valgrind-3.16.1 && ./autogen.sh && ./configure && make -j 4 && make install && rm -rf /tmp/valgrind* ; fi

RUN if [ X"${ARCH}" = X"i386" ] ; then apt remove -y cmake && cd /tmp && wget https://github.com/Kitware/CMake/releases/download/v3.22.1/cmake-3.22.1.tar.gz && tar xzvf cmake-3.22.1.tar.gz && cd cmake-3.22.1 && ./bootstrap && make && make install && rm -rf /tmp/cmake* ; fi

ENV JAVA_HOME="/usr/lib/jvm/java-1.11.0-openjdk-amd64"
