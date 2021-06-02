ARG GO_VER=1.15.6
ARG ALPINE_VER=3.12

FROM golang:${GO_VER}-alpine${ALPINE_VER} as builder
WORKDIR /root
RUN apk add --no-cache gcc libc-dev

COPY ./ /root/chaincode

WORKDIR /root/chaincode

RUN go build -v -mod=readonly -o ./build/app ./bin

FROM alpine:${ALPINE_VER}

COPY --from=builder /root/chaincode/build/app /usr/bin/app

WORKDIR /root

CMD ["/usr/bin/app"]
