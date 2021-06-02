.PHONY: build
build:
	make -C chaincode build \
	&& make -C contract build \
	&& make -C relayer build

.PHONY: setup
setup: start-fabric prepare

.PHONY: start-fabric
start-fabric:
	make -C chaincode docker-image
	make -C networks/fabric start

.PHONY: prepare
prepare:
	make \
	RLY_BINARY=${CURDIR}/relayer/build/uly \
	TM_BINARY=${CURDIR}/contract/build/simd \
	MSPS_DIR=${CURDIR}/networks/fabric/msps \
	-C tests prepare

.PHONY: transfer
transfer:
	make \
	RLY_BINARY=${CURDIR}/relayer/build/uly \
	TM_BINARY=${CURDIR}/contract/build/simd \
	MSPS_DIR=${CURDIR}/networks/fabric/msps \
	-C tests test

.PHONY: stop
stop:
	make -C networks/fabric down
# currently, you should kill a simd manually to avoid killing a wrong one
#	pkill simd

.PHONY: clean
clean:
	make -C networks/fabric clean
	make -C tests clean
