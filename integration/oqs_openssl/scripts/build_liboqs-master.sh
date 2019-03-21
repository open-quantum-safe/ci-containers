#!/bin/bash

set -e

OPENSSL_DIR=${OPENSSL_DIR:-"/usr"}
PREFIX=${OPENSSL_SRC_DIR:-"`pwd`/tmp/openssl/oqs"}

cd tmp/liboqs
autoreconf -i
./configure --prefix=${PREFIX} --enable-shared=no --enable-openssl --with-openssl-dir=${OPENSSL_DIR}
make -j
make install
