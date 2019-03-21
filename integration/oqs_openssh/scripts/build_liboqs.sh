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
    make -j OPENSSL_INCLUDE_DIR="${PREFIX}/include" OPENSSL_LIB_DIR="${PREFIX}/lib"
    make install-noshared PREFIX=${PREFIX}
else
    cd tmp/liboqs
    autoreconf -i
    if [ "x${CIRCLECI}" == "xtrue"]; then
        BIKEARG="--distable-kem-bike"
        # FIXME: BIKE doesn't work on CircleCI due to symbol _CMP_LT_OS not being defined
    else
        BIKEARG=
    fi
    ./configure --prefix=${PREFIX} --with-pic=yes --enable-openssl --with-openssl-dir=${PREFIX} ${BIKEARG}
    make -j
    make install
fi
