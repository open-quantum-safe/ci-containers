#!/bin/bash

###########
# Build liboqs
#
# Environment variables:
#  - LIBOQS: either master (default) or nist
#  - PREFIX: path to install liboqs, default `pwd`/tmp/install
###########

set -exo pipefail

PREFIX=${PREFIX:-"`pwd`/tmp/install"}

if [ "x${LIBOQS}" == "xnist" ]; then
    cd tmp/liboqs
    if [ "x${CIRCLECI}" == "xtrue" ] || [ "x${TRAVIS}" == "xtrue" ]; then
        make -j2 OPENSSL_INCLUDE_DIR="${PREFIX}/include" OPENSSL_LIB_DIR="${PREFIX}/lib"
    else
        make -j OPENSSL_INCLUDE_DIR="${PREFIX}/include" OPENSSL_LIB_DIR="${PREFIX}/lib"
    fi
    make install-noshared PREFIX=${PREFIX}
else
    cd tmp/liboqs
    autoreconf -i
    if [ "x${CIRCLECI}" == "xtrue" ]; then
        BIKEARG="--disable-kem-bike"
        # FIXME: BIKE doesn't work on CircleCI due to symbol _CMP_LT_OS not being defined
    else
        BIKEARG=
    fi
    ./configure --prefix=${PREFIX} --with-pic=yes --enable-openssl --with-openssl-dir=${PREFIX} ${BIKEARG}
    if [ "x${CIRCLECI}" == "xtrue" ] || [ "x${TRAVIS}" == "xtrue" ]; then
        make -j2
    else
        make -j
    fi
    make install
fi
