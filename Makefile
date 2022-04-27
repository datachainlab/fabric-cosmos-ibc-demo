.PHONY: build
build:
	make -C chaincode build \
	&& make -C contract build \
	&& make -C relayer build

.PHONY: setup
setup: start-cosmos start-fabric prepare

.PHONY: start-fabric
start-fabric:
	make -C networks/fabric start

.PHONY: start-cosmos
start-cosmos:
	make -C networks/cosmos up

.PHONY: prepare
prepare:
	make \
	RLY_BINARY=${CURDIR}/relayer/build/uly \
	TM_BINARY=${CURDIR}/contract/build/simd \
	MSPS_DIR=${CURDIR}/networks/fabric/msps \
	TM_DATA_DIR=${CURDIR}/networks/cosmos/fixtures/data \
	-C tests prepare

.PHONY: transfer
transfer:
	make \
	RLY_BINARY=${CURDIR}/relayer/build/uly \
	TM_BINARY=${CURDIR}/contract/build/simd \
	MSPS_DIR=${CURDIR}/networks/fabric/msps \
	TM_DATA_DIR=${CURDIR}/networks/cosmos/fixtures/data \
	-C tests test

.PHONY: stop
stop:
	make -C networks down

.PHONY: stop-fabric
stop-fabric:
	make -C networks/fabric down

.PHONY: stop-cosmos
stop-cosmos:
	make -C networks/cosmos down

.PHONY: clean
clean:
	make -C networks/fabric clean
	make -C networks/cosmos clean
	make -C tests clean
