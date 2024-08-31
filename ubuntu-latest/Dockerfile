FROM ubuntu:latest
LABEL version="2"

RUN DEBIAN_FRONTEND=noninteractive TZ=Europe/Zurich && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get update -qq && \
    apt-get dist-upgrade -y && \
    apt-get install -y tzdata && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt-get install -y apt-utils wget \
                       autoconf \
                       automake \
                       astyle \
                       clang \
                       clang-format \
                       clang-tools \
                       cmake \
                       docker.io \
                       gcc \
                       gcc-mingw-w64 \
                       g++ \
                       git \
                       libtool \
                       libssl-dev \
                       libunwind-dev \
                       make \
                       ninja-build \
                       npm \
                       opam \
                       pkg-config \
                       python3 \
                       python3-git \
                       python3-nose \
                       python3-rednose \
                       python3-pytest \
                       python3-pytest-xdist \
                       python3-psutil \
                       python3-pip \
                       python3-tabulate \
                       python3-jinja2 \
                       zlib1g-dev \
                       maven \
                       openjdk-11-jdk \
                       valgrind \
                       flex bison \
                       lsb-release software-properties-common \
                       lcov \
                       graphviz \
                       llvm \
                       golang \
                       doxygen \
                       yamllint

# set up jasmin compiler for libjade
RUN opam init --yes --auto-setup && opam install --confirm-level=unsafe-yes --destdir=/usr/local jasmin.2023.06.3

# install ajv for CBOM validation
RUN npm -g install ajv ajv-cli

# actionlint - for GitHub workflow file validation
# (version pinned to commit hash of v1.7.1)
FROM golang:1.23 AS build
RUN mkdir /app
WORKDIR /app
ENV CGO_ENABLED 0
RUN git clone https://github.com/rhysd/actionlint.git
WORKDIR /app/actionlint
RUN git reset --hard 62dc61a
RUN go build -o /usr/local/bin/actionlint ./cmd/actionlint
# copy built binary from build stage to final image
FROM ubuntu:latest
COPY --from=build /usr/local/bin/actionlint /usr/local/bin/actionlint

# Activate if we want to test specific OpenSSL3 versions:
# RUN cd /root && git clone --depth 1 --branch openssl-3.0.7 https://github.com/openssl/openssl.git && cd openssl && LDFLAGS="-Wl,-rpath -Wl,/usr/local/openssl3/lib64"  ./config --prefix=/usr/local/openssl3 && make -j && make install
