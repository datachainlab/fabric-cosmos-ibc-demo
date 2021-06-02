#!/usr/bin/env bash
set -eu pipefail

FABRIC_CFG_PATH=${PWD}/config
CC_NAME=${CC_NAME:="trade"}
CC_SRC_PATH=/opt/gopath/src/chaincodedev/chaincode/${CC_NAME}
CC_RUNTIME_LANGUAGE=golang
VERSION=${VERSION:="1"}

# import utils
. ./scripts/setEnv.sh

packageChaincode() {
    ORG_NUM=$1
    ORG_NAME=$2

    echo "### Package Chaincode ${CC_NAME}"
#    peer lifecycle chaincode package ${CC_NAME}.tar.gz --path ${CC_SRC_PATH} --lang ${CC_RUNTIME_LANGUAGE} --label ${CC_NAME}
    pushd ./external/config/${ORG_NAME}
    tar cfz code.tar.gz connection.json
    tar cfz ${CC_NAME}-${ORG_NAME}.tar.gz code.tar.gz metadata.json
    mv ${CC_NAME}-${ORG_NAME}.tar.gz ../../../build
    popd
}

installChaincode() {
    CHANNEL_NAME=$1
    ORG_NUM=$2
    ORG_NAME=$3

    setGlobals ${ORG_NUM}
    set -x
    peer lifecycle chaincode install ./build/${CC_NAME}-${ORG_NAME}.tar.gz
    set +x
}

queryInstalled() {
    ORG_NUM=$1
    ORG_NAME=$2

    setGlobals ${ORG_NUM}
    set -x
    peer lifecycle chaincode queryinstalled >&log.txt
    set +x
    cat log.txt
    PACKAGE_ID=$(sed -n "/${CC_NAME}/{s/^Package ID: //; s/, Label:.*$//; p;}" log.txt)
    echo ${PACKAGE_ID} &> ./build/${ORG_NAME}-ccid.txt
}

approveForMyOrg() {
    CHANNEL_NAME=$1
    SIGNATURE_POLICY=$2
    ORG_NUM=$3
    ORG_NAME=$4

    setGlobals ${ORG_NUM}
    PACKAGE_ID=$(cat ./build/${ORG_NAME}-ccid.txt)
    set -x
    peer lifecycle chaincode approveformyorg \
    -o orderer.example.com:7050 \
    --channelID ${CHANNEL_NAME} \
    --name ${CC_NAME} \
    --version ${VERSION} \
    --sequence ${VERSION} \
    --package-id ${PACKAGE_ID} \
    --signature-policy ${SIGNATURE_POLICY}

    peer lifecycle chaincode checkcommitreadiness \
    --channelID ${CHANNEL_NAME} \
    --name ${CC_NAME} \
    --version ${VERSION} \
    --sequence ${VERSION} \
    --signature-policy ${SIGNATURE_POLICY} \
    --output json
    set +x
}

commitChaincode() {
    CHANNEL_NAME=$1
    SIGNATURE_POLICY=$2
    ORG_NUM=$3

    PEER_CONN_PARAMS=""
    for org in ${@:4}; do
      setGlobals ${org}
      PEER_CONN_PARAMS="$PEER_CONN_PARAMS --peerAddresses $CORE_PEER_ADDRESS"
    done

    setGlobals ${ORG_NUM}
    set -x
    peer lifecycle chaincode commit \
    -o orderer.example.com:7050 \
    --channelID ${CHANNEL_NAME} \
    --name ${CC_NAME} \
    --version ${VERSION} \
    --sequence ${VERSION} ${PEER_CONN_PARAMS} \
    --signature-policy ${SIGNATURE_POLICY}

    peer lifecycle chaincode querycommitted --channelID ${CHANNEL_NAME} --name ${CC_NAME}
    set +x
}

mkdir -p ./build

packageChaincode 1 PlatformerOrg
installChaincode channel1 1 PlatformerOrg
SIGNATURE_POLICY="AND('PlatformerMSP.peer')"
queryInstalled 1 PlatformerOrg
approveForMyOrg channel1 ${SIGNATURE_POLICY} 1 PlatformerOrg
commitChaincode channel1 ${SIGNATURE_POLICY} 1
