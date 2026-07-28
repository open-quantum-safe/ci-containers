FROM ubuntu:jammy
LABEL version="4"
ARG ARCH

RUN export DEBIAN_FRONTEND=noninteractive TZ=Europe/Zurich && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get update -qq && \
    apt-get dist-upgrade -y && \
    apt-get install -y apt-utils wget \
                       autoconf \
                       automake \
                       astyle \
                       clang \
                       clang-format \
                       cmake \
                       docker.io \
                       gcc \
                       g++ \
                       git \
                       libgmp-dev \
                       libtool \
                       libssl-dev \
                       libunwind-dev \
                       make \
                       ninja-build \
                       pkg-config \
                       python3 \
                       python3-pytest \
                       python3-pytest-xdist \
                       python3-psutil \
                       python3-pip \
                       python3-requests \
                       zlib1g-dev \
                       maven \
                       openjdk-11-jdk \
                       qemu \
                       valgrind \
                       flex bison \
                       lsb-release software-properties-common \
                       lcov \
                       graphviz \
                       golang \
                       yamllint && \
     pip3 install tabulate jinja2

RUN git clone --depth 1 --branch Release_1_10_0 https://github.com/doxygen/doxygen.git /doxygen
WORKDIR /doxygen/build
RUN cmake -G "Unix Makefiles" .. && make -j 4 && make install && doxygen --version
WORKDIR /

# Ubuntu names the JDK directory after the Debian architecture (amd64), not the
# ARCH build-arg this image is passed (x86_64), so JAVA_HOME is resolved here
# rather than interpolated. The javac check fails the build if the JDK moves,
# instead of leaving a JAVA_HOME that silently points nowhere.
RUN ln -sfn "/usr/lib/jvm/java-1.11.0-openjdk-$(dpkg --print-architecture)" /usr/lib/jvm/java-11 && \
    [ -x /usr/lib/jvm/java-11/bin/javac ]
ENV JAVA_HOME="/usr/lib/jvm/java-11"
# Activate if we want to test specific OpenSSL3 versions:
# RUN cd /root && git clone --depth 1 --branch openssl-3.0.7 https://github.com/openssl/openssl.git && cd openssl && LDFLAGS="-Wl,-rpath -Wl,/usr/local/openssl3/lib64"  ./config --prefix=/usr/local/openssl3 && make -j && make install
