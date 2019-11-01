#!/bin/bash

###########
# Build OpenSSH
#
# Environment variables:
#  - PREFIX: path to install OpenSSH, default `pwd`/tmp/install
#  - WITH_OPENSSL: build OpenSSH with (true, default) or without (false) OpenSSL
###########

set -exo pipefail

PREFIX=${PREFIX:-"`pwd`/tmp/install"}
WITH_OPENSSL=${WITH_OPENSSL:-"true"}

cd tmp/openssh
autoreconf -i
if [ "x${WITH_OPENSSL}" == "xtrue" ]; then
    ./configure --prefix="${PREFIX}" --without-openssl-header-check --with-ldflags="-Wl,-rpath -Wl,${PREFIX}/lib" --with-libs=-lm --with-ssl-dir="${PREFIX}" --with-liboqs-dir="${PREFIX}" --with-cflags="-I${PREFIX}/include" --sysconfdir="${PREFIX}"
    cat Makefile
    cat config.log
else
    ./configure --prefix="${PREFIX}" --with-ldflags="-Wl,-rpath -Wl,${PREFIX}/lib" --with-libs=-lm --without-openssl --with-liboqs-dir="${PREFIX}" --with-cflags="-I${PREFIX}/include" --sysconfdir="${PREFIX}"
fi
if [ "x${CIRCLECI}" == "xtrue" ] || [ "x${TRAVIS}" == "xtrue" ]; then
    make -j2
else
    make -j
fi
make install
