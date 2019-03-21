#!/bin/bash

###########
# Do a full run through of a single liboqs/OpenSSH integration test combination
#
# Environment variables:
#  - ARCH: either x64 (default) or x86
#  - LIBOQS: either master (default) or nist
#
# The following environment variables affect subsequent scripts:
#  - LIBOQS_MASTER_REPO: which repo to check out from, default https://github.com/open-quantum-safe/liboqs.git
#  - LIBOQS_MASTER_BRANCH: which branch to check out, default master
#  - LIBOQS_NIST_REPO: which repo to check out from, default https://github.com/open-quantum-safe/liboqs.git
#  - LIBOQS_NIST_BRANCH: which branch to check out, default nist-branch
#  - OPENSSH_REPO: which repo to check out from, default https://github.com/open-quantum-safe/openssh-portable.git
#  - OPENSSH_BRANCH: which branch to check out, default OQS-master
#  - WITH_OPENSSL: build OpenSSH with (true, default) or without (false) OpenSSL
#  - WITH_PQAUTH: build OpenSSH with (true, default) or without (false) post-quantum authentication
###########

set -eo pipefail

ARCH=${ARCH:-"x64"}

scripts/clone_openssl.sh
scripts/build_openssl.sh
scripts/clone_liboqs.sh
scripts/build_liboqs.sh
scripts/clone_openssh.sh
scripts/build_openssh.sh
python3 -m nose --rednose --verbose
