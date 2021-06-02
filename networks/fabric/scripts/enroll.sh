#!/usr/bin/env bash

set -eux

enrollCAAdmin() {
    CA_NAME=$1
    CA_SERVER_ENDPOINT=$2

    echo
    echo "Enroll the CA admin of ${CA_NAME}"
    echo
    fabric-ca-client enroll -u https://admin:adminpw@${CA_SERVER_ENDPOINT} --caname ${CA_NAME} --tls.certfiles ${PWD}/config/fabric-ca/${CA_NAME}/tls-cert.pem
}

registerOrdererUsers() {
    ORG_NAME=$1
    CA_NAME=$2

    echo
	echo "Register orderer"
    echo
    fabric-ca-client register --caname ${CA_NAME} --id.name ${ORG_NAME} --id.secret ${ORG_NAME}pw --id.type orderer --tls.certfiles ${PWD}/config/fabric-ca/${CA_NAME}/tls-cert.pem

    echo
    echo "Register the orderer admin"
    echo
    fabric-ca-client register --caname ${CA_NAME} --id.name ${ORG_NAME}Admin --id.secret ${ORG_NAME}Adminpw --id.type admin --tls.certfiles ${PWD}/config/fabric-ca/${CA_NAME}/tls-cert.pem
}

enrollOrdererUsers() {
    ORG_NAME=$1
    CA_NAME=$2
    CA_SERVER_ENDPOINT=$3

    echo
    echo "## Generate the orderer msp"
    echo
    fabric-ca-client enroll -u https://${ORG_NAME}:${ORG_NAME}pw@${CA_SERVER_ENDPOINT} --caname ${CA_NAME} -M ${FABRIC_CA_CLIENT_HOME}/orderers/orderer.example.com/msp --csr.hosts orderer.example.com --csr.hosts orderer.example.com --tls.certfiles ${PWD}/config/fabric-ca/${CA_NAME}/tls-cert.pem

    echo
    echo "## Generate the orderer-tls certificates"
    echo
    fabric-ca-client enroll -u https://${ORG_NAME}:${ORG_NAME}pw@${CA_SERVER_ENDPOINT} --caname ${CA_NAME} -M ${FABRIC_CA_CLIENT_HOME}/orderers/orderer.example.com/tls --csr.hosts orderer.example.com --csr.hosts orderer.example.com --enrollment.profile tls --tls.certfiles ${PWD}/config/fabric-ca/${CA_NAME}/tls-cert.pem

    echo
    echo "## Generate the admin msp"
    echo
    fabric-ca-client enroll -u https://${ORG_NAME}:${ORG_NAME}pw@${CA_SERVER_ENDPOINT} --caname ${CA_NAME} -M ${FABRIC_CA_CLIENT_HOME}/users/Admin@example.com/msp --tls.certfiles ${PWD}/config/fabric-ca/${CA_NAME}/tls-cert.pem

    CERT=${CA_SERVER_ENDPOINT//[.:]/-}-${CA_NAME}.pem
    echo "NodeOUs:
    Enable: true
    ClientOUIdentifier:
      Certificate: cacerts/${CERT}
      OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
      Certificate: cacerts/${CERT}
      OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
      Certificate: cacerts/${CERT}
      OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
      Certificate: cacerts/${CERT}
      OrganizationalUnitIdentifier: orderer" > ${FABRIC_CA_CLIENT_HOME}/msp/config.yaml

    cp ${FABRIC_CA_CLIENT_HOME}/msp/config.yaml ${FABRIC_CA_CLIENT_HOME}/orderers/orderer.example.com/msp/config.yaml
    cp ${FABRIC_CA_CLIENT_HOME}/msp/config.yaml ${FABRIC_CA_CLIENT_HOME}/users/Admin@example.com/msp/config.yaml
}

registerOrgUsers() {
    ORG_NAME=$1
    CA_NAME=$2
    echo
    echo "Register peer0 of ${ORG_NAME}"
    echo
    fabric-ca-client register --caname ${CA_NAME} --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles ${PWD}/config/fabric-ca/${CA_NAME}/tls-cert.pem

    echo
    echo "Register platformer user of ${ORG_NAME}"
    echo
    fabric-ca-client register --caname ${CA_NAME} --id.name user1 --id.secret user1pw --id.type client --tls.certfiles ${PWD}/config/fabric-ca/${CA_NAME}/tls-cert.pem

    echo
    echo "Register importer user of ${ORG_NAME}"
    echo
    fabric-ca-client register --caname ${CA_NAME} --id.name importer --id.secret importerpw --id.type client --tls.certfiles ${PWD}/config/fabric-ca/${CA_NAME}/tls-cert.pem

    echo
    echo "Register exporter user of ${ORG_NAME}"
    echo
    fabric-ca-client register --caname ${CA_NAME} --id.name exporter --id.secret exporterpw --id.type client --tls.certfiles ${PWD}/config/fabric-ca/${CA_NAME}/tls-cert.pem

    echo
    echo "Register the org admin of ${ORG_NAME}"
    echo
    fabric-ca-client register --caname ${CA_NAME} --id.name ${ORG_NAME}admin --id.secret ${ORG_NAME}adminpw --id.type admin --tls.certfiles ${PWD}/config/fabric-ca/${CA_NAME}/tls-cert.pem

    echo
    echo "Register the org ibc policy signer of ${ORG_NAME}"
    echo
    fabric-ca-client register --caname ${CA_NAME} --id.name ${ORG_NAME}ibcsigner --id.secret ${ORG_NAME}ibcsignerpw --id.type admin --tls.certfiles ${PWD}/config/fabric-ca/${CA_NAME}/tls-cert.pem
}

enrollOrgUsers() {
    ORG_NAME=$1
    CA_NAME=$2
    CA_SERVER_ENDPOINT=$3

    echo
    echo "## Generate the peer0 msp"
    echo
    fabric-ca-client enroll -u https://peer0:peer0pw@${CA_SERVER_ENDPOINT} --caname ${CA_NAME} -M ${FABRIC_CA_CLIENT_HOME}/peers/peer0.${ORG_NAME}.example.com/msp --csr.hosts peer0.${ORG_NAME}.example.com --tls.certfiles ${PWD}/config/fabric-ca/${CA_NAME}/tls-cert.pem

    echo
    echo "## Generate the peer0-tls certificates"
    echo
    fabric-ca-client enroll -u https://peer0:peer0pw@${CA_SERVER_ENDPOINT} --caname ${CA_NAME} -M ${FABRIC_CA_CLIENT_HOME}/peers/peer0.${ORG_NAME}.example.com/tls --enrollment.profile tls --csr.hosts peer0.${ORG_NAME}.example.com --csr.hosts ca.${ORG_NAME}.example.com --tls.certfiles ${PWD}/config/fabric-ca/${CA_NAME}/tls-cert.pem

    echo
    echo "## Generate the user msp"
    echo
    fabric-ca-client enroll -u https://user1:user1pw@${CA_SERVER_ENDPOINT} --caname ${CA_NAME} -M ${FABRIC_CA_CLIENT_HOME}/users/User1@${ORG_NAME}.example.com/msp --tls.certfiles ${PWD}/config/fabric-ca/${CA_NAME}/tls-cert.pem

    echo
    echo "## Generate the importer msp"
    echo
    fabric-ca-client enroll -u https://importer:importerpw@${CA_SERVER_ENDPOINT} --caname ${CA_NAME} -M ${FABRIC_CA_CLIENT_HOME}/users/Importer@${ORG_NAME}.example.com/msp --tls.certfiles ${PWD}/config/fabric-ca/${CA_NAME}/tls-cert.pem

    echo
    echo "## Generate the importer msp"
    echo
    fabric-ca-client enroll -u https://exporter:exporterpw@${CA_SERVER_ENDPOINT} --caname ${CA_NAME} -M ${FABRIC_CA_CLIENT_HOME}/users/Exporter@${ORG_NAME}.example.com/msp --tls.certfiles ${PWD}/config/fabric-ca/${CA_NAME}/tls-cert.pem

    echo
    echo "## Generate the org admin msp"
    echo
    fabric-ca-client enroll -u https://${ORG_NAME}admin:${ORG_NAME}adminpw@${CA_SERVER_ENDPOINT} --caname ${CA_NAME} -M ${FABRIC_CA_CLIENT_HOME}/users/Admin@${ORG_NAME}.example.com/msp --tls.certfiles ${PWD}/config/fabric-ca/${CA_NAME}/tls-cert.pem

    echo
    echo "## Generate the org ibc signer msp"
    echo
    fabric-ca-client enroll -u https://${ORG_NAME}ibcsigner:${ORG_NAME}ibcsignerpw@${CA_SERVER_ENDPOINT} --caname ${CA_NAME} -M ${FABRIC_CA_CLIENT_HOME}/users/IbcSigner@${ORG_NAME}.example.com/msp --tls.certfiles ${PWD}/config/fabric-ca/${CA_NAME}/tls-cert.pem

    CERT=${CA_SERVER_ENDPOINT//[.:]/-}-${CA_NAME}.pem
    echo "NodeOUs:
    Enable: true
    ClientOUIdentifier:
      Certificate: cacerts/${CERT}
      OrganizationalUnitIdentifier: client
    PeerOUIdentifier:
      Certificate: cacerts/${CERT}
      OrganizationalUnitIdentifier: peer
    AdminOUIdentifier:
      Certificate: cacerts/${CERT}
      OrganizationalUnitIdentifier: admin
    OrdererOUIdentifier:
      Certificate: cacerts/${CERT}
      OrganizationalUnitIdentifier: orderer" > ${FABRIC_CA_CLIENT_HOME}/msp/config.yaml

    cp ${FABRIC_CA_CLIENT_HOME}/msp/config.yaml ${FABRIC_CA_CLIENT_HOME}/peers/peer0.${ORG_NAME}.example.com/msp
    cp ${FABRIC_CA_CLIENT_HOME}/msp/config.yaml ${FABRIC_CA_CLIENT_HOME}/users/User1@${ORG_NAME}.example.com/msp
    cp ${FABRIC_CA_CLIENT_HOME}/msp/config.yaml ${FABRIC_CA_CLIENT_HOME}/users/Importer@${ORG_NAME}.example.com/msp
    cp ${FABRIC_CA_CLIENT_HOME}/msp/config.yaml ${FABRIC_CA_CLIENT_HOME}/users/Exporter@${ORG_NAME}.example.com/msp
    cp ${FABRIC_CA_CLIENT_HOME}/msp/config.yaml ${FABRIC_CA_CLIENT_HOME}/users/Admin@${ORG_NAME}.example.com/msp
    cp ${FABRIC_CA_CLIENT_HOME}/msp/config.yaml ${FABRIC_CA_CLIENT_HOME}/users/IbcSigner@${ORG_NAME}.example.com/msp
}

export FABRIC_CA_CLIENT_HOME=${PWD}/msps/OrdererMSP/
enrollCAAdmin OrdererCA ca.example.com:8054
registerOrdererUsers orderer OrdererCA
enrollOrdererUsers orderer OrdererCA ca.example.com:8054

export FABRIC_CA_CLIENT_HOME=${PWD}/msps/PlatformerMSP/
enrollCAAdmin PlatformerCA ca.platformer.example.com:7054
registerOrgUsers platformer PlatformerCA
enrollOrgUsers platformer PlatformerCA ca.platformer.example.com:7054
