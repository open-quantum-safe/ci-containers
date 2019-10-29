#!/bin/bash

###########
# Build OpenSSL docker image
#
# Must be run after OQSLL has been built (and tested OK) 
###########

set -exo pipefail

case "$OSTYPE" in
    linux*)   echo "Copying over required files from tmp/openssl..."  ;;
    *)        echo "Operating system: $OSTYPE not configured for dockerization" ; exit 1 ;;
esac
# copy required files over:
pwd
ls -l
cp tmp/openssl/apps/openssl scripts/dockerizer
mkdir scripts/dockerizer/include
mkdir scripts/dockerizer/lib
cp tmp/openssl/libcrypto.a scripts/dockerizer/lib
cp tmp/openssl/libssl.a scripts/dockerizer/lib
cp tmp/openssl/oqs/lib/liboqs.a scripts/dockerizer/lib
cp -R tmp/openssl/oqs/include/oqs scripts/dockerizer/include
cp -R tmp/openssl/include/openssl scripts/dockerizer/include

cd scripts/dockerizer && docker build -t ubuntu-oqssl . 
