#!/bin/bash

set -e

REPO=${LIBOQS_MASTER_REPO:-"https://github.com/open-quantum-safe/liboqs.git"}
BRANCH=${LIBOQS_MASTER_BRANCH:-"master"}

rm -rf tmp/liboqs
git clone --branch ${BRANCH} --single-branch ${REPO} tmp/liboqs
