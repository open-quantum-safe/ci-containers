#!/bin/bash

###########
# Clone OpenSSL source code
#
# Environment variables:
#  - OPENSSL: either 102 or 111 (default)
#  - OPENSSL_102_REPO: which repo to check out from, default https://github.com/open-quantum-safe/openssl.git
#  - OPENSSL_102_BRANCH: which branch to check out, default OQS-OpenSSL_1_0_2-stable
#  - OPENSSL_111_REPO: which repo to check out from, default https://github.com/open-quantum-safe/openssl.git
#  - OPENSSL_111_BRANCH: which branch to check out, default OQS-OpenSSL_1_1_1-stable
###########

set -eo pipefail

if [ "x${OPENSSL}" == "x102" ]; then
    REPO=${OPENSSL_102_REPO:-"https://github.com/open-quantum-safe/openssl.git"}
    BRANCH=${OPENSSL_102_BRANCH:-"OQS-OpenSSL_1_0_2-stable"}
else
    REPO=${OPENSSL_111_REPO:-"https://github.com/open-quantum-safe/openssl.git"}
    BRANCH=${OPENSSL_111_BRANCH:-"OQS-OpenSSL_1_1_1-stable"}
fi

rm -rf tmp/openssl
git clone --branch ${BRANCH} --single-branch ${REPO} tmp/openssl
