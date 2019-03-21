#!/bin/bash

###########
# Run all liboqs/OpenSSL integration test combinations
#
# The following environment variables affect subsequent scripts:
#  - ARCH: either x64 (default) or x86
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

set -e

PRINT_GREEN="tput setaf 2"
PRINT_RESET="tput sgr 0"

for LIBOQS in "master" "nist" ; do
    for OPENSSL in "111" "102" ; do
        ${PRINT_GREEN}
        echo "================================================================="
        echo "================================================================="
        echo "liboqs / OpenSSL integration test"
        echo " - LIBOQS=${LIBOQS}"
        echo " - OPENSSL=${OPENSSL}"
        echo "================================================================="
        echo "================================================================="
        ${PRINT_RESET}
        export LIBOQS
        export OPENSSL
        rm -rf tmp
        ./run.sh
    done
done
