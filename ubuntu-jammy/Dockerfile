FROM ubuntu:jammy
LABEL version="1"
ARG ARCH

RUN DEBIAN_FRONTEND=noninteractive TZ=Europe/Zurich && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get update -qq && \
    apt-get dist-upgrade -y && \
    apt-get install -y apt-utils wget && \
    wget https://go.dev/dl/go1.19.3.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.19.3.linux-amd64.tar.gz && \
    cp /usr/local/go/bin/* /usr/bin && \
    apt-get install -y autoconf \
                       automake \
                       astyle \
                       clang \
                       cmake \
                       docker.io \
                       gcc \
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
                       valgrind \
                       flex bison \
                       lsb-release software-properties-common \
                       lcov \
                       graphviz \
                       yamllint

RUN cd / && git clone --depth 1 --branch Release_1_9_2 https://github.com/doxygen/doxygen.git && cd doxygen && mkdir build && cd build && cmake -G "Unix Makefiles" .. && make -j 4 && make install && doxygen --version 
RUN cd /root && wget https://apt.llvm.org/llvm.sh && chmod u+x llvm.sh && ./llvm.sh 14 all
ENV JAVA_HOME="/usr/lib/jvm/java-1.11.0-openjdk-amd64"
# Activate if we want to test specific OpenSSL3 versions:
# RUN cd /root && git clone --depth 1 --branch openssl-3.0.7 https://github.com/openssl/openssl.git && cd openssl && LDFLAGS="-Wl,-rpath -Wl,/usr/local/openssl3/lib64"  ./config --prefix=/usr/local/openssl3 && make -j && make install
