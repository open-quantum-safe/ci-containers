#!/bin/bash

###########
# Clone OpenSSL source code
###########

set -exo pipefail

REPO="https://github.com/openssl/openssl.git"
BRANCH="OpenSSL_1_0_2-stable"

rm -rf tmp/openssl
git clone --branch ${BRANCH} --single-branch ${REPO} tmp/openssl
