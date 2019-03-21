#!/bin/bash

###########
# Build OpenSSL
#
# Same script works for both OQS-OpenSSL_1_0_2-stable and OQS-OpenSSL_1_1_1-stable.
# Must be run after OQS has been installed inside the OpenSSL source code directory
###########

set -e

cd tmp/openssl
case "$OSTYPE" in
    darwin*)  ./Configure no-shared darwin64-x86_64-cc ;;
    linux*)   ./Configure no-shared linux-x86_64 -lm  ;;
    *)        echo "Unknown operating system: $OSTYPE" ; exit 1 ;;
esac

if [ "x${OPENSSL}" == "x102" ]; then
    make
else
    if [ "x${CIRCLECI}" == "xtrue" ]; then
        make -j2
    else
        make -j
    fi
fi
