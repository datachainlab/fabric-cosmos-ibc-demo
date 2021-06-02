DOCKER?=docker

.PHONY: build
build:
	go build -mod=readonly -o ./build/simd ./simapp/simd

.PHONY: image-simd
image-simd:
	$(DOCKER) build -t simd -f ./docker/Dockerfile .
