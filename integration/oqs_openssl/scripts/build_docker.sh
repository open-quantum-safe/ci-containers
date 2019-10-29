#!/bin/bash

###########
# Build OpenSSL docker image
#
# Must be run after OQSLL has been built (and tested OK) 
###########

set -exo pipefail

cd tmp/openssl
case "$OSTYPE" in
    linux*)   ./Configure no-shared linux-x86_64 -lm  ;;
    *)        echo "Operating system: $OSTYPE not configured for dockerization" ; exit 1 ;;
esac

# copy required files over:
pwd
ls -l

cd dockerizer && docker build -t ubuntu-oqssl .
