FROM ubuntu:latest as base
LABEL version="3"

# actionlint - for GitHub workflow file validation
# (version pinned to commit hash of v1.7.1)
FROM golang:1.23 as build
RUN mkdir /app
WORKDIR /app
ENV CGO_ENABLED 0
RUN git clone https://github.com/rhysd/actionlint.git
WORKDIR /app/actionlint
RUN git reset --hard 03d0035 # v1.7.7
RUN go build -o /usr/local/bin/actionlint ./cmd/actionlint

# jasmin compiler for libjade - built via opam in its own stage so the
# OCaml toolchain (ocaml, libcompiler-libs-ocaml-dev, opam itself, ~1.1GB
# combined) never ends up in the final image, only the resulting
# jasminc binary + whatever it dynamically links against. Mirrors the
# actionlint pattern above, which already does this for the Go toolchain.
FROM ubuntu:latest as jasmin-build
RUN DEBIAN_FRONTEND=noninteractive apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        opam \
        gcc \
        make \
        pkg-config \
        libgmp-dev \
        ca-certificates
RUN opam init --yes --auto-setup && \
    opam install --confirm-level=unsafe-yes --destdir=/opt/jasmin-install jasmin.2023.06.3

# copy built binary from build stage to final image
FROM ubuntu:latest
WORKDIR /root
COPY --from=build /usr/local/bin/actionlint /usr/local/bin/actionlint

ARG ARCH
ENV ARCH=${ARCH}

RUN DEBIAN_FRONTEND=noninteractive TZ=Europe/Zurich && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt-get update -qq && \
    apt-get dist-upgrade -y && \
    apt-get install -y --no-install-recommends tzdata && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt-get install -y --no-install-recommends apt-utils wget \
                       xz-utils \
                       autoconf \
                       automake \
                       astyle \
                       clang \
                       clang-format \
                       clang-tools \
                       libclang-rt-dev \
                       cmake \
                       curl \
                       default-jdk-headless \
                       docker.io \
                       gcc \
                       gcc-mingw-w64-x86-64 \
                       g++ \
                       git \
                       libgmp-dev \
                       libtool \
                       libssl-dev \
                       libunwind-dev \
                       make \
                       ninja-build \
                       npm \
                       pkg-config \
                       python3 \
                       python3-git \
                       python3-pytest \
                       python3-pytest-xdist \
                       python3-psutil \
                       python3-pip \
                       python3-tabulate \
                       python3-jinja2 \
                       python3-requests \
                       zlib1g-dev \
                       maven \
                       valgrind \
                       flex bison \
                       lsb-release software-properties-common \
                       lcov \
                       graphviz \
                       golang \
                       doxygen \
                       yamllint \
                       libmpfr6 \
                       libppl14 && \
    rm -rf /var/lib/apt/lists/*

# install ajv for CBOM validation
RUN npm -g install ajv ajv-cli

# jasmin compiler for libjade, built in the jasmin-build stage above.
# jasminc dynamically links against apron's native-stub libraries
# (libapron.so, libboxMPQ.so, liboctMPQ.so, libap_ppl.so), which opam
# installs directly under the switch's share/ directory rather than
# somewhere --destdir exports -- verified via `ldd`, see PR discussion.
# libmpfr6/libppl14 above cover apron's own further system-level deps.
COPY --from=jasmin-build /opt/jasmin-install /usr/local
COPY --from=jasmin-build /root/.opam/default/share/apron/lib/ /usr/local/lib/
RUN ldconfig && jasminc -version

# set up Kyberslash patch for Valgrind-based constant-time testing
COPY valgrind-try-patch-20250805.txt /tmp/
COPY valgrind-varlat-patch-20250805.txt /tmp/
COPY valgrind-varlat-sup-block.txt /tmp/

RUN git clone git://sourceware.org/git/valgrind.git /tmp/valgrind_varlat_src && \
    cd /tmp/valgrind_varlat_src && \
    git checkout 112f1080b7c21e37dfce0a2e589d0dc7aa115afa && \
    git apply /tmp/valgrind-try-patch-20250805.txt && \
    git apply /tmp/valgrind-varlat-patch-20250805.txt && \
    git apply /tmp/valgrind-varlat-sup-block.txt && \
    ./autogen.sh && \
    ./configure --prefix=/opt/valgrind_varlat && \
    make -j"$(nproc)" && \
    make install && \
    mv /opt/valgrind_varlat/bin/valgrind /opt/valgrind_varlat/bin/valgrind_varlat && \
    cd / && rm -rf /tmp/valgrind_varlat_src /tmp/*.txt

ENV PATH="/opt/valgrind_varlat/bin:${PATH}"

# set JAVA_HOME for liboqs-java builds
ENV JAVA_HOME="/usr/lib/jvm/default-java"

# point AddressSanitizer at binutils' addr2line for symbolization. The usual
# symbolizer, llvm-symbolizer, ships only in the ~98MB llvm metapackage that
# was dropped above; addr2line is a symbolizer compiler-rt supports natively
# and gcc already pulls it in via binutils, so this costs 0MB. Without it,
# sanitizer reports degrade to bare addresses -- no function, file or line.
# See https://github.com/open-quantum-safe/ci-containers/pull/108 for the
# measurements behind this.
#
# IMPORTANT: consumers needing their own ASan settings must APPEND to this
# value rather than replace it, e.g.
#     ASAN_OPTIONS="${ASAN_OPTIONS}:detect_leaks=0"
# (":" and " " both separate flags). Overwriting ASAN_OPTIONS outright is
# silent: the sanitizer still catches errors and jobs still fail correctly,
# but the reports lose symbolization again with no warning of its own.
ENV ASAN_OPTIONS="external_symbolizer_path=/usr/bin/addr2line"

