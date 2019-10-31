#!/bin/bash

###########
# Build OpenSSL docker image
#
# Must be run after OQSLL has been built (and tested OK) 
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

# copy required files over:
echo "BASE: $BASE"
cp -R /opt/oqssl scripts/dockerizer/$BASE

cd scripts/dockerizer/$BASE && docker build -t $IMAGE-run .  
