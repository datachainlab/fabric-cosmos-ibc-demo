#!/bin/bash
set -eu pipefail

# import utils
. ./scripts/setEnv.sh

createChannel() {
    CHANNEL_NAME=$1
    ORG_NUM=$2

    setGlobals ${ORG_NUM}
    echo "### Creating channel ${CHANNEL_NAME}"
    peer channel create -c ${CHANNEL_NAME} -f ./artifacts/${CHANNEL_NAME}.tx -o orderer.example.com:7050
    echo "### Creating channel ${CHANNEL_NAME} Done"
}

joinChannel() {
    CHANNEL_NAME=$1
    ORG_NUM=$2
    ORG_NAME=$3

    setGlobals ${ORG_NUM}
    echo "### Join channel ${CHANNEL_NAME} ${ORG_NAME}"
    peer channel join -b ./${CHANNEL_NAME}.block -o orderer.example.com:7050
    echo "### Join channel ${CHANNEL_NAME} ${ORG_NAME} Done"
}

updateAnchorPeers() {
  CHANNEL_NAME=$1
  ORG_NUM=$2
  ORG_NAME=$3

  setGlobals ${ORG_NUM}
  peer channel update -o orderer.example.com:7050 -c ${CHANNEL_NAME} -f ./artifacts/${ORG_NAME}Anchors.tx
}

createChannel channel1 1
joinChannel channel1 1 PlatformerOrg
updateAnchorPeers channel1 1 PlatformerOrg

sleep 600000
exit 0
