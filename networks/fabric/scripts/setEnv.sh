#!/usr/bin/env bash

set -eu

setGlobals() {
  USING_ORG=$1
  echo "Using organization ${USING_ORG}"
  if [[ ${USING_ORG} -eq 1 ]]; then
    export CORE_PEER_ID=peer0.platformer.example.com
    export CORE_PEER_LOCALMSPID=PlatformerMSP
    export CORE_PEER_ADDRESS=peer0.platformer.example.com:7051
    export CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/chaincodedev/msps/PlatformerMSP/users/Admin@platformer.example.com/msp
  else
    echo "================== ERROR !!! ORG Unknown =================="
    exit 1
  fi
}

