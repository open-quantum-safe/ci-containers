#!/bin/bash

set -e

cd tmp/openssl
case "$OSTYPE" in
  darwin*)  ./Configure no-shared darwin64-x86_64-cc ;;
  linux*)   ./Configure no-shared linux-x86_64  ;;
  *)        echo "Unknown operating system: $OSTYPE" ; exit 1 ;;
esac
make -j
