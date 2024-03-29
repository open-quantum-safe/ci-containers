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
                       python3-pip \
                       zlib1g-dev \
                       maven \
                       openjdk-11-jdk \
                       qemu \
                       libc6-dbg

RUN if [ X"${ARCH}" != X"i386" ] ; then cd /tmp && wget https://sourceware.org/pub/valgrind/valgrind-3.16.1.tar.bz2 && tar -xf valgrind-3.16.1.tar.bz2 && cd valgrind-3.16.1 && ./autogen.sh && ./configure && make -j 4 && make install && rm -rf /tmp/valgrind* ; fi

RUN pip3 install cmake==3.22.1

ENV JAVA_HOME="/usr/lib/jvm/java-1.11.0-openjdk-amd64"

RUN cmake --version