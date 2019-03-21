#!/bin/bash

###########
# Build OpenSSL
#
# Environment variables:
#  - PREFIX: path to install OpenSSL, default `pwd`/tmp/install
###########

set -exo pipefail

PREFIX=${PREFIX:-"`pwd`/tmp/install"}

cd tmp/openssl
case "$OSTYPE" in
    darwin*) CFLAGS=-fPIC ./Configure shared darwin64-x86_64-cc --prefix=${PREFIX} ;;
    linux*)  CFLAGS=-fPIC ./Configure shared linux-x86_64 --prefix=${PREFIX} ;;
    *)       echo "Unknown operating system: $OSTYPE" ; exit 1 ;;
esac
make
make install_sw
