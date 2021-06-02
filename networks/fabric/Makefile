DOCKER?=docker

FABRIC_BIN_DIR?=$(CURDIR)/../../.bin
SCRIPT_DIR?=$(CURDIR)/scripts

FABRIC_VERSION?=2.2.1
CA_VERSION?=1.4.7
DOCKER_NETWORK=fabric-dev

export PATH := $(FABRIC_BIN_DIR):$(PATH)

ifeq  ($(shell uname),Darwin)
IP_CMD?=ifconfig en0
else
IP_CMD?=ip -4 addr show docker0
endif

LOCAL_HOST_IP?=$(shell $(IP_CMD) | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | awk '{print $1}')

.PHONY: clean
clean:
	rm -rf $(CURDIR)/artifacts
	rm -rf $(CURDIR)/build
	rm -rf $(CURDIR)/external/config/**/traceability/code.tar.gz
	rm -rf $(CURDIR)/organizations
	$(SCRIPT_DIR)/clean.sh

.PHONY: configtx
configtx:
	$(SCRIPT_DIR)/configtx.sh

#.PHONY: cryptogen
#cryptogen:
#	$(FABRIC_BIN_DIR)/cryptogen generate --config $(CURDIR)/cryptogen/crypto-config.yaml --output $(CURDIR)/organizations

.PHONY: up-ca
up-ca:
	CA_IMAGE_TAG=$(CA_VERSION) \
	$(DOCKER) compose -f docker-compose-ca.yaml up -d

.PHONY: enroll
enroll:
	docker run --rm \
	--net $(DOCKER_NETWORK) \
	--workdir="/root/fabibc" \
	--volume $(CURDIR)/config/fabric-ca:/root/fabibc/config/fabric-ca \
	--volume $(CURDIR)/msps:/root/fabibc/msps \
	--volume $(CURDIR)/scripts:/root/fabibc/scripts \
	hyperledger/fabric-ca:$(CA_VERSION) \
	/bin/bash -c "./scripts/enroll.sh"

.PHONY: init
init:
	rm -rf ./artifacts
	docker run --rm \
	--workdir="/root" \
	--volume $(CURDIR)/scripts:/root/scripts \
	--volume $(CURDIR)/config:/root/config \
	--volume $(CURDIR)/msps:/root/msps \
	--volume $(CURDIR)/artifacts:/root/artifacts \
	hyperledger/fabric-tools:$(FABRIC_VERSION) \
	bash -c "./scripts/init.sh"

.PHONY: up
up:
	LOCAL_HOST_IP=$(shell docker network inspect $(DOCKER_NETWORK) | jq -r ".[].IPAM.Config[].Gateway") \
	IMAGE_TAG=$(FABRIC_VERSION) \
	LOGGING_SPEC=info \
	$(DOCKER) compose up -d

.PHONY: down-ca
down-ca:
	CA_IMAGE_TAG=$(CA_VERSION) \
	$(DOCKER) compose -f docker-compose-ca.yaml down -v

.PHONY: start
start: clean up-ca enroll init up
	make deployCC
	$(SCRIPT_DIR)/startCC.sh

.PHONY: createChannel
createChannel:
	$(SCRIPT_DIR)/createChannel.sh

.PHONY: deployCC
deployCC:
	$(DOCKER) compose exec -T fabric-cli bash -c "./scripts/deployCC.sh"

.PHONY: startCC
startCC:
	$(SCRIPT_DIR)/startCC.sh

.PHONY: down
down:
	LOCAL_HOST_IP=$(LOCAL_HOST_IP) IMAGE_TAG=$(FABRIC_VERSION) LOGGING_SPEC=$(LOGGING_SPEC) \
	CA_IMAGE_TAG=$(CA_VERSION) \
	$(DOCKER) compose \
	-f docker-compose-cc.yaml \
	-f docker-compose-ca.yaml \
	-f docker-compose.yaml \
	down --volumes --remove-orphans

.PHONY: restart
restart:
	$(MAKE) down
	$(MAKE) start
