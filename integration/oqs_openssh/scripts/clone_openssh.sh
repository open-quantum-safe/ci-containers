#!/bin/bash

###########
# Clone OpenSSH source code
#
# Environment variables:
#  - OPENSSH_REPO: which repo to check out from, default https://github.com/open-quantum-safe/openssh-portable.git
#  - OPENSSH_BRANCH: which branch to check out, default OQS-master
###########

set -eo pipefail

REPO=${OPENSSH_REPO:-"https://github.com/open-quantum-safe/openssh-portable.git"}
BRANCH=${OPENSSH_BRANCH:-"OQS-master"}

rm -rf tmp/openssh
git clone --branch ${BRANCH} --single-branch ${REPO} tmp/openssh
