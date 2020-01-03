#!/bin/bash

###########
# Build liboqs
#
# Environment variables:
#  - LIBOQS: either master (default) or nist
#  - OPENSSL_DIR: path to system OpenSSL installation; default /usr
#  - PREFIX: path to install liboqs, default `pwd`/tmp/openssl/oqs
#  - LINKTYPE: either static or dynamic (dynamic default)
###########

set -exo pipefail

OPENSSL_DIR=${OPENSSL_DIR:-"/usr"}
PREFIX=${OPENSSL_SRC_DIR:-"`pwd`/tmp/openssl/oqs"}

if [[ -z ${LINKTYPE} ]]; then
   export LINKTYPE="dynamic"
fi

cd tmp/liboqs
autoreconf -i

if [ "$LINKTYPE" == "static" ]; then
    ./configure --prefix=${PREFIX} --enable-shared=no --with-openssl=${OPENSSL_DIR}
else
    ./configure --prefix=${PREFIX} --enable-shared=yes --with-openssl=${OPENSSL_DIR}
fi

if [ "x${CIRCLECI}" == "xtrue" ] || [ "x${TRAVIS}" == "xtrue" ]; then
    make -j2
else
    make -j
fi
make install
