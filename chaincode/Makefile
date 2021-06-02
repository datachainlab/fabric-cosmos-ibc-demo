.PHONY: build
build:
	go build -mod=readonly -o $(CURDIR)/build/app $(CURDIR)/bin

.PHONY: build-image
build-image:
	docker build -t datachainlab/fabric-cosmos-ibc-demo-chaincode -f $(CURDIR)/docker/app/Dockerfile .
