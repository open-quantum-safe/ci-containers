#!/bin/bash

###########
# Clone liboqs source code
#
# Environment variables:
#  - LIBOQS: either master (default) or nist
#  - LIBOQS_MASTER_REPO: which repo to check out from, default https://github.com/open-quantum-safe/liboqs.git
#  - LIBOQS_MASTER_BRANCH: which branch to check out, default master
#  - LIBOQS_NIST_REPO: which repo to check out from, default https://github.com/open-quantum-safe/liboqs.git
#  - LIBOQS_NIST_BRANCH: which branch to check out, default nist-branch
###########

set -exo pipefail

if [ "x${LIBOQS}" == "xnist" ]; then
    REPO=${LIBOQS_NIST_REPO:-"https://github.com/open-quantum-safe/liboqs.git"}
    BRANCH=${LIBOQS_NIST_BRANCH:-"nist-branch"}
else
    REPO=${LIBOQS_MASTER_REPO:-"https://github.com/open-quantum-safe/liboqs.git"}
    BRANCH=${LIBOQS_MASTER_BRANCH:-"master"}
fi

rm -rf tmp/liboqs
git clone --branch ${BRANCH} --single-branch ${REPO} tmp/liboqs
