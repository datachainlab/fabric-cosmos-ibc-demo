.PHONY: build
build:
	go build -mod=readonly -o ./build/simd ./simapp/simd

.PHONY: build-image
build-image:
	docker build -t datachainlab/fabric-cosmos-ibc-demo-simd -f ./docker/Dockerfile .
