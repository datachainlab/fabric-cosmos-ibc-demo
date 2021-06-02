.PHONY: build
build:
	go build -mod=readonly -o $(CURDIR)/build/app $(CURDIR)/bin

.PHONY: docker-image
docker-image:
	docker build -t chaincode-transfer -f $(CURDIR)/docker/app/Dockerfile .
