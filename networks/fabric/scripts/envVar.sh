#!/usr/bin/env bash

source scripts/scriptUtils.sh

export PATH=${PWD}/bin:$PATH
export FABRIC_CFG_PATH=${PWD}/config
export CORE_PEER_TLS_ENABLED=true

COMPOSE_FILE_BASE=docker/docker-compose-platform.yaml
COMPOSE_FILE_CORPORATION_BASE=docker/docker-compose-corporation.yaml
COMPOSE_FILE_CA=docker/docker-compose-platform-ca.yaml
COMPOSE_FILE_CORPORATION_CA=docker/docker-compose-corporation-ca.yaml

PLATFORM_PEER_ADDRESS=peer0.platform.example.com:7051
PLATFORM_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/platform.example.com/peers/peer0.platform.example.com/tls/ca.crt
CORPORATION1_PEER_ADDRESS=peer0.corporation1.example.com:7051
CORPORATION1_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/corporation1.example.com/peers/peer0.corporation1.example.com/tls/ca.crt
CORPORATION2_PEER_ADDRESS=peer0.corporation2.example.com:7051
CORPORATION2_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/corporation2.example.com/peers/peer0.corporation2.example.com/tls/ca.crt
CORPORATION3_PEER_ADDRESS=peer0.corporation3.example.com:7051
CORPORATION3_PEER_TLS_ROOTCERT_FILE=${PWD}/organizations/peerOrganizations/corporation3.example.com/peers/peer0.corporation3.example.com/tls/ca.crt

ORDERER_CA_PLATFORM=${PWD}/organizations/ordererOrganizations/platform.example.com/orderers/orderer.platform.example.com/msp/tlscacerts/tlsca.platform.example.com-cert.pem
ORDERER_CA_PLATFORM_DATA=${PWD}/organizations/ordererOrganizations/platform.example.com/orderers/data-orderer.platform.example.com/msp/tlscacerts/tlsca.platform.example.com-cert.pem
ORDERER_CA_CORPORATION1=${PWD}/organizations/ordererOrganizations/corporation1.example.com/orderers/orderer.corporation1.example.com/msp/tlscacerts/tlsca.corporation1.example.com-cert.pem
ORDERER_CA_CORPORATION1_DATA=${PWD}/organizations/ordererOrganizations/corporation1.example.com/orderers/data-orderer.corporation1.example.com/msp/tlscacerts/tlsca.corporation1.example.com-cert.pem
ORDERER_CA_CORPORATION2=${PWD}/organizations/ordererOrganizations/corporation2.example.com/orderers/orderer.corporation2.example.com/msp/tlscacerts/tlsca.corporation2.example.com-cert.pem
ORDERER_CA_CORPORATION2_DATA=${PWD}/organizations/ordererOrganizations/corporation2.example.com/orderers/data-orderer.corporation2.example.com/msp/tlscacerts/tlsca.corporation2.example.com-cert.pem
ORDERER_CA_CORPORATION3=${PWD}/organizations/ordererOrganizations/corporation3.example.com/orderers/orderer.corporation3.example.com/msp/tlscacerts/tlsca.corporation3.example.com-cert.pem
ORDERER_CA_CORPORATION3_DATA=${PWD}/organizations/ordererOrganizations/corporation3.example.com/orderers/data-orderer.corporation3.example.com/msp/tlscacerts/tlsca.corporation3.example.com-cert.pem
ORDERER_ADDRESS_PLATFORM=orderer.platform.example.com:7050
ORDERER_ADDRESS_PLATFORM_DATA=data-orderer.platform.example.com:7050
ORDERER_ADDRESS_CORPORATION1=orderer.corporation1.example.com:7050
ORDERER_ADDRESS_CORPORATION1_DATA=data-orderer.corporation1.example.com:7050
ORDERER_ADDRESS_CORPORATION2=orderer.corporation2.example.com:7050
ORDERER_ADDRESS_CORPORATION2_DATA=data-orderer.corporation2.example.com:7050
ORDERER_ADDRESS_CORPORATION3=orderer.corporation3.example.com:7050
ORDERER_ADDRESS_CORPORATION3_DATA=data-orderer.corporation3.example.com:7050

# Set environment variables for the peer org
setGlobals() {
  PEER_HOSTNAME=$1
  ORDERER_HOSTNAME=${2:-"-"}

  # Peer
  infoln "Using peer ${PEER_HOSTNAME}"
  if [ $PEER_HOSTNAME = "peer0.platform.example.com" ]; then
    export CORE_PEER_LOCALMSPID="PlatformMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PLATFORM_PEER_TLS_ROOTCERT_FILE
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/platform.example.com/users/Admin@platform.example.com/msp
    export CORE_PEER_ADDRESS=$PLATFORM_PEER_ADDRESS
  elif [ $PEER_HOSTNAME = "peer0.corporation1.example.com" ]; then
    export CORE_PEER_LOCALMSPID="Corporation1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$CORPORATION1_PEER_TLS_ROOTCERT_FILE
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/corporation1.example.com/users/Admin@corporation1.example.com/msp
    export CORE_PEER_ADDRESS=$CORPORATION1_PEER_ADDRESS
  elif [ $PEER_HOSTNAME = "peer0.corporation2.example.com" ]; then
    export CORE_PEER_LOCALMSPID="Corporation2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$CORPORATION2_PEER_TLS_ROOTCERT_FILE
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/corporation2.example.com/users/Admin@corporation2.example.com/msp
    export CORE_PEER_ADDRESS=$CORPORATION2_PEER_ADDRESS
  elif [ $PEER_HOSTNAME = "peer0.corporation3.example.com" ]; then
    export CORE_PEER_LOCALMSPID="Corporation3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$CORPORATION3_PEER_TLS_ROOTCERT_FILE
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/corporation3.example.com/users/Admin@corporation3.example.com/msp
    export CORE_PEER_ADDRESS=$CORPORATION3_PEER_ADDRESS
  else
    errorln "Unknown peer ${PEER_HOSTNAME}"
  fi

  # Orderer
  if [ $ORDERER_HOSTNAME != "-" ]; then
    infoln "Using orderer ${ORDERER_HOSTNAME}"
  fi

  if [ $ORDERER_HOSTNAME = "orderer.platform.example.com" ]; then
    ORDERER_CA=$ORDERER_CA_PLATFORM
    ORDERER_ADDRESS=$ORDERER_ADDRESS_PLATFORM
  elif [ $ORDERER_HOSTNAME = "data-orderer.platform.example.com" ]; then
    ORDERER_CA=$ORDERER_CA_PLATFORM_DATA
    ORDERER_ADDRESS=$ORDERER_ADDRESS_PLATFORM_DATA
  elif [ $ORDERER_HOSTNAME = "orderer.corporation1.example.com" ]; then
    ORDERER_CA=$ORDERER_CA_CORPORATION1
    ORDERER_ADDRESS=$ORDERER_ADDRESS_CORPORATION1
  elif [ $ORDERER_HOSTNAME = "data-orderer.corporation1.example.com" ]; then
    ORDERER_CA=$ORDERER_CA_CORPORATION1_DATA
    ORDERER_ADDRESS=$ORDERER_ADDRESS_CORPORATION1_DATA
  elif [ $ORDERER_HOSTNAME = "orderer.corporation2.example.com" ]; then
    ORDERER_CA=$ORDERER_CA_CORPORATION2
    ORDERER_ADDRESS=$ORDERER_ADDRESS_CORPORATION2
  elif [ $ORDERER_HOSTNAME = "data-orderer.corporation2.example.com" ]; then
    ORDERER_CA=$ORDERER_CA_CORPORATION2_DATA
    ORDERER_ADDRESS=$ORDERER_ADDRESS_CORPORATION2_DATA
  elif [ $ORDERER_HOSTNAME = "orderer.corporation3.example.com" ]; then
    ORDERER_CA=$ORDERER_CA_CORPORATION3
    ORDERER_ADDRESS=$ORDERER_ADDRESS_CORPORATION3
  elif [ $ORDERER_HOSTNAME = "data-orderer.corporation3.example.com" ]; then
    ORDERER_CA=$ORDERER_CA_CORPORATION3_DATA
    ORDERER_ADDRESS=$ORDERER_ADDRESS_CORPORATION3_DATA
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep -E "CORE|ORDERER"
  fi
}
