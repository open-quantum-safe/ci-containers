#!/bin/bash

###########
# Build OpenSSH
#
# Environment variables:
#  - PREFIX: path to install OpenSSH, default `pwd`/tmp/install
#  - WITH_OPENSSL: build OpenSSH with (true, default) or without (false) OpenSSL
#  - WITH_PQAUTH: build OpenSSH with (true, default) or without (false) post-quantum authentication
###########

set -eo pipefail

PREFIX=${PREFIX:-"`pwd`/tmp/install"}
WITH_OPENSSL=${WITH_OPENSSL:-"true"}
WITH_PQAUTH=${WITH_PQAUTH:-"true"}

if [ "x${WITH_PQAUTH}" == "xtrue" ]; then
    PQAUTH_ARG="--enable-pq-auth"
else
    PQAUTH_ARG=""
fi

cd tmp/openssh
autoreconf -i
if [ "x${WITH_OPENSSL}" == "xtrue" ]; then
    ./configure --prefix="${PREFIX}" --enable-pq-kex --enable-hybrid-kex ${PQAUTH_ARG} --with-ldflags="-Wl,-rpath -Wl,${PREFIX}/lib" --with-libs=-lm --with-ssl-dir="${PREFIX}" --with-liboqs-dir="${PREFIX}" --with-cflags="-I${PREFIX}/include" --sysconfdir="${PREFIX}"
else
    ./configure --prefix="${BASEDIR}/install" --enable-pq-kex --enable-hybrid-kex ${PQAUTH_ARG} --with-ldflags="-Wl,-rpath -Wl,${PREFIX}/lib" --with-libs=-lm --without-openssl --with-liboqs-dir="${PREFIX}" --with-cflags="-I${PREFIX}/include" --sysconfdir="${PREFIX}"
fi
if [ "x${CIRCLECI}" == "xtrue" ]; then
    make -j2
else
    make -j
fi
make install
