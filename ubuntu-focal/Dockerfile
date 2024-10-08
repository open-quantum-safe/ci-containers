ARG ARCH
FROM ubuntu:focal
LABEL version="5"
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
                       clang-9 \
                       cmake \
                       docker.io \
                       gcc gcc-7 gcc-8\
                       gcc-mingw-w64\
                       g++ \
                       git \
                       libtool \
                       libssl-dev \
                       libunwind-dev \
                       make \
                       ninja-build \
                       npm \
                       pkg-config \
                       python3 \
                       python3-git \
                       python3-nose \
                       python3-rednose \
                       python3-pytest \
                       python3-pytest-xdist \
                       python3-psutil \
                       python3-wget \
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
                       sudo \
                       curl \
                       yamllint && \
    npm -g install ajv ajv-cli && \
    pip3 install tabulate jinja2

RUN if [ "$ARCH" = "amd64" ] || [ "$ARCH" = "x64" ] || [ "$ARCH" = "x86_64" ]; then cd / && git clone --depth 1 --branch Release_1_10_0 https://github.com/doxygen/doxygen.git && cd doxygen && mkdir build && cd build && cmake -G "Unix Makefiles" .. && make -j 4 && make install && doxygen --version ; fi
RUN cd /root && wget https://apt.llvm.org/llvm.sh && chmod u+x llvm.sh && ./llvm.sh 15 all
ENV JAVA_HOME="/usr/lib/jvm/java-1.11.0-openjdk-amd64"
