#!/usr/bin/env bash
set -eux

export FABRIC_CFG_PATH=${PWD}/config

createChannelTx() {
    PROFILE=$1
    ORG_NAME=$2
    CHANNEL_NAME=$3

    configtxgen \
    -profile ${PROFILE} \
    -channelID ${CHANNEL_NAME} \
    -outputCreateChannelTx ./artifacts/${CHANNEL_NAME}.tx \
    -asOrg ${ORG_NAME}
}

createAnchorPeerTx() {
    PROFILE=$1
    ORG_NAME=$2
    CHANNEL_NAME=$3

	configtxgen \
    -profile ${PROFILE} \
    -channelID ${CHANNEL_NAME} \
    -outputAnchorPeersUpdate ./artifacts/${ORG_NAME}Anchors.tx \
    -asOrg ${ORG_NAME}
}

configtxgen \
-profile OrdererGenesis \
-channelID system-channel \
-outputBlock ./artifacts/orderer.block

createChannelTx Channel1 PlatformerMSP channel1
createAnchorPeerTx Channel1 PlatformerOrg channel1
