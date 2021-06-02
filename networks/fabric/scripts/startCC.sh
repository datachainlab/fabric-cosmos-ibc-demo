#!/usr/bin/env bash
set -eu pipefail

CHAINCODE_CCID_PLATFORMER=$(cat ./build/PlatformerOrg-ccid.txt)

set -x
CHAINCODE_CCID_PLATFORMER=${CHAINCODE_CCID_PLATFORMER} \
docker-compose -f docker-compose-cc.yaml up -d
