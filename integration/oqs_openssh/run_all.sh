#!/bin/bash

###########
# Run all liboqs/OpenSSH integration test combinations
#
# The following environment variables affect subsequent scripts:
#  - ARCH: either x64 (default) or x86
#  - LIBOQS: either master (default) or nist
#  - LIBOQS_MASTER_REPO: which repo to check out from, default https://github.com/open-quantum-safe/liboqs.git
#  - LIBOQS_MASTER_BRANCH: which branch to check out, default master
#  - LIBOQS_NIST_REPO: which repo to check out from, default https://github.com/open-quantum-safe/liboqs.git
#  - LIBOQS_NIST_BRANCH: which branch to check out, default nist-branch
#  - OPENSSH_REPO: which repo to check out from, default https://github.com/open-quantum-safe/openssh-portable.git
#  - OPENSSH_BRANCH: which branch to check out, default OQS-master
###########

set -eo pipefail

PRINT_GREEN="tput setaf 2"
PRINT_RESET="tput sgr 0"

for LIBOQS in "master" "nist" ; do
    for WITH_OPENSSL in "true" "false" ; do
        for WITH_PQAUTH in "true" "false" ; do
            if [ "x${LIBOQS}" == "xnist" ]; then
                continue
            fi
            ${PRINT_GREEN}
            echo "================================================================="
            echo "================================================================="
            echo "liboqs / OpenSSH integration test"
            echo " - LIBOQS=${LIBOQS}"
            echo " - WITH_OPENSSL=${WITH_OPENSSL}"
            echo " - WITH_PQAUTH=${WITH_PQAUTH}"
            echo "================================================================="
            echo "================================================================="
            ${PRINT_RESET}
            export LIBOQS
            export WITH_OPENSSL
            export WITH_PQAUTH
            rm -rf tmp
            ./run.sh
    done
done
