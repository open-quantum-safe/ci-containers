ARG ARCH
FROM multiarch/ubuntu-core:${ARCH}-focal
LABEL version="1"

RUN DEBIAN_FRONTEND=noninteractive TZ=Europe/Zurich && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get update -qq && \
    apt-get dist-upgrade -y && \
    apt-get install -y apt-utils wget && \
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
                       valgrind

ENV JAVA_HOME="/usr/lib/jvm/java-1.11.0-openjdk-amd64"
