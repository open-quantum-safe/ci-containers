#!/bin/bash

###########
# Build liboqs
#
# Environment variables:
#  - LIBOQS: either master (default) or nist
#  - OPENSSL_DIR: path to system OpenSSL installation; default /usr
#  - PREFIX: path to install liboqs, default `pwd`/tmp/openssl/oqs
###########

set -e

OPENSSL_DIR=${OPENSSL_DIR:-"/usr"}
PREFIX=${OPENSSL_SRC_DIR:-"`pwd`/tmp/openssl/oqs"}

if [ "x${LIBOQS}" == "xnist" ]; then
    cd tmp/liboqs
    make -j
    make install-noshared PREFIX="${PREFIX}"
else
    cd tmp/liboqs
    autoreconf -i
    ./configure --prefix=${PREFIX} --enable-shared=no --enable-openssl --with-openssl-dir=${OPENSSL_DIR}
    make -j
    make install
fi
