#!/bin/bash

set -e

REPO=${OPENSSL_111_REPO:-"https://github.com/open-quantum-safe/openssl.git"}
BRANCH=${OPENSSL_111_BRANCH:-"OQS-OpenSSL_1_1_1-stable"}

rm -rf tmp/openssl
git clone --branch ${BRANCH} --single-branch ${REPO} tmp/openssl
