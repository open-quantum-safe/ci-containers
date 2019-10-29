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
cd scripts
# copy required files over:
pwd
ls -l
cp tmp/openssl/apps/openssl dockerizer
mkdir dockerizer/include
mkdir dockerizer/lib
cp tmp/openssl/libcrypto.a dockerizer/lib
cp tmp/openssl/libssl.a dockerizer/lib
cp tmp/openssl/oqs/lib/liboqs.a dockerizer/lib
cp -R tmp/openssl/oqs/include/oqs dockerizer/include
cp -R tmp/openssl/include/openssl dockerizer/include

cd dockerizer && docker build -t ubuntu-oqssl .
