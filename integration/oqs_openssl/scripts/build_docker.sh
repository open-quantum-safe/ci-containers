#!/bin/bash

###########
# Build OpenSSL docker image
#
# Must be run after OQSS* has been built (and tested OK) 
# Environment variables:
# IMAGE: Defines the docker image we're running (and which is consequently being created)
###########

set -exo pipefail

# IMAGE defines the Dockerfile-folder to be populated so needs to be present
if [[ -z $IMAGE ]]; then
   echo "IMAGE must be set in environment to proceed. Exiting."
   exit -1
fi

BASE=`echo $IMAGE | sed -e 's/openqsafe\///g'`

# Move build images in place:
cp scripts/dockerizer/$BASE/* /opt
cp scripts/dockerizer/*entrypoint* /opt/oqssa/bin
cd /opt && docker build -f Dockerfile-dev -t $IMAGE-dev . && cd -

# Add demo scripts to run image:
cp scripts/dockerizer/oqs-* /opt/oqssa/bin
cd /opt && docker build -f Dockerfile -t $IMAGE-run . && cd -

