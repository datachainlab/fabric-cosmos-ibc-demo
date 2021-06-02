#!/usr/bin/env bash

set -eux pipefail

function clearContainers() {
  CONTAINER_IDS=$(docker ps -a | awk '($2 ~ /dev-peer.*/) {print $1}')
  if [[ -z "$CONTAINER_IDS" || "$CONTAINER_IDS" == " " ]]; then
    echo "---- No containers available for deletion ----"
  else
    docker rm -f ${CONTAINER_IDS}
  fi
}

function removeUnwantedImages() {
  DOCKER_IMAGE_IDS=$(docker images | awk '($1 ~ /dev-peer.*/) {print $3}')
  if [[ -z "$DOCKER_IMAGE_IDS" || "$DOCKER_IMAGE_IDS" == " " ]]; then
    echo "---- No images available for deletion ----"
  else
    docker rmi -f ${DOCKER_IMAGE_IDS}
  fi
}

#docker-compose -f docker-compose.yaml -f docker-compose-cc.yaml -f docker-compose-ca.yaml down --volumes --remove-orphans
docker-compose -f docker-compose-ca.yaml down --volumes --remove-orphans
clearContainers
removeUnwantedImages

rm -rf ./artifacts/*.block ./artifacts/*.tx
rm -rf ./build/*
rm -rf ./*.block

rm -rf msps/**
rm -rf config/fabric-ca/OrdererCA/msp config/fabric-ca/OrdererCA/tls-cert.pem config/fabric-ca/OrdererCA/ca-cert.pem config/fabric-ca/OrdererCA/IssuerPublicKey config/fabric-ca/OrdererCA/IssuerRevocationPublicKey config/fabric-ca/OrdererCA/fabric-ca-server.db
rm -rf config/fabric-ca/PlatformerCA/msp config/fabric-ca/PlatformerCA/tls-cert.pem config/fabric-ca/PlatformerCA/ca-cert.pem config/fabric-ca/PlatformerCA/IssuerPublicKey config/fabric-ca/PlatformerCA/IssuerRevocationPublicKey config/fabric-ca/PlatformerCA/fabric-ca-server.db


