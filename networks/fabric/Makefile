FABRIC_BIN_DIR?=$(CURDIR)/../../.bin
SCRIPT_DIR?=$(CURDIR)/scripts

FABRIC_VERSION?=2.2.1
CA_VERSION?=1.4.7
DOCKER_NETWORK=dev

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

.PHONY: up-ca
up-ca:
	CA_IMAGE_TAG=$(CA_VERSION) \
	docker-compose -f ../docker-compose.yaml up -d \
		ca.platformer.example.com \
		ca.example.com

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
	docker-compose -f ../docker-compose.yaml up -d \
		orderer.example.com \
		peer0.platformer.example.com \
		fabric-cli

.PHONY: down-ca
down-ca:
	CA_IMAGE_TAG=$(CA_VERSION) \
	docker-compose -f ../docker-compose.yaml \
		rm -fsv \
		ca.platformer.example.com \
		ca.example.com

.PHONY: start
start: clean up-ca enroll init up
	make deployCC
	$(SCRIPT_DIR)/startCC.sh

.PHONY: createChannel
createChannel:
	$(SCRIPT_DIR)/createChannel.sh

.PHONY: deployCC
deployCC:
	docker-compose -f ../docker-compose.yaml \
	exec -T fabric-cli /bin/bash -c "scripts/deployCC.sh"

.PHONY: startCC
startCC:
	$(SCRIPT_DIR)/startCC.sh

.PHONY: down
down: down-ca
	LOCAL_HOST_IP=$(LOCAL_HOST_IP) IMAGE_TAG=$(FABRIC_VERSION) LOGGING_SPEC=$(LOGGING_SPEC) \
	CA_IMAGE_TAG=$(CA_VERSION) \
	docker-compose \
	-f ../docker-compose.yaml \
	rm -fsv \
	orderer.example.com \
	peer0.platformer.example.com \
	fabric-cli

.PHONY: restart
restart:
	$(MAKE) down
	$(MAKE) start
