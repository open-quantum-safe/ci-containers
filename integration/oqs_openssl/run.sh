#!/bin/bash

###########
# Do a full run through of a single liboqs/OpenSSL integration test combination
#
# Environment variables:
#  - ARCH: either x64 (default) or x86
#  - LIBOQS: either master (default) or nist
#  - OPENSSL: either 102 or 111 (default)
#
# The following environment variables affect subsequent scripts:
#  - OPENSSL_DIR: path to system OpenSSL installation; default /usr
#  - OPENSSL_102_REPO: which repo to check out from, default https://github.com/open-quantum-safe/openssl.git
#  - OPENSSL_102_BRANCH: which branch to check out, default OQS-OpenSSL_1_0_2-stable
#  - OPENSSL_111_REPO: which repo to check out from, default https://github.com/open-quantum-safe/openssl.git
#  - OPENSSL_111_BRANCH: which branch to check out, default OQS-OpenSSL_1_1_1-stable
#  - LIBOQS_MASTER_REPO: which repo to check out from, default https://github.com/open-quantum-safe/liboqs.git
#  - LIBOQS_MASTER_BRANCH: which branch to check out, default master
#  - LIBOQS_NIST_REPO: which repo to check out from, default https://github.com/open-quantum-safe/liboqs.git
#  - LIBOQS_NIST_BRANCH: which branch to check out, default nist-branch
###########

set -eo pipefail

ARCH=${ARCH:-"x64"}

scripts/clone_liboqs.sh
scripts/clone_openssl.sh
scripts/build_liboqs.sh
scripts/build_openssl.sh
python3 -m nose --rednose --verbose
