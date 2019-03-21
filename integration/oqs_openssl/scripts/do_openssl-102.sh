#!/bin/bash

###########
# Run one client/server interaction in OpenSSL 1.0.2
#
# Environment variables:
#  - KEXALG: key exchange algorithm to use
#  - SIGALG: signature algorithm to use
#  - PORT: port to run server on
###########

set -exo pipefail

CIPHER=${KEXALG}

apps/openssl s_server -cert ${SIGALG}_srv.crt -key ${SIGALG}_srv.key -tls1_2 -www -accept ${PORT} &
sleep 1
SERVER_PID=$!
echo "GET /" | apps/openssl s_client -cipher "${CIPHER}" -connect "localhost:${PORT}" > s_client_${PORT}.out 2>/dev/null
cat s_client_${PORT}.out | grep "Cipher is" | grep "${CIPHER}" > /dev/null
kill ${SERVER_PID}
