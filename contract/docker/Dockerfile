ARG GO_VER=1.15.6
ARG ALPINE_VER=3.12

FROM golang:${GO_VER}-alpine${ALPINE_VER} as build-env

# Install minimum necessary dependencies,
ENV PACKAGES curl make git libc-dev bash gcc linux-headers eudev-dev python3
RUN apk add --no-cache $PACKAGES

# Add source files
COPY ./ /root/contract

# Set working directory for the build
WORKDIR /root/contract

RUN make build
# install simapp, remove packages
#RUN make build-linux

# Final image
FROM alpine:${ALPINE_VER}

# Install ca-certificates
RUN apk add --update ca-certificates
WORKDIR /root

# Copy over binaries from the build-env
COPY --from=build-env /root/contract/build/simd /usr/bin/simd

EXPOSE 26656 26657 1317 9090

# Run simd by default, omit entrypoint to ease using container with simcli
CMD ["simd"]
