# Support setting various labels on the final image
ARG COMMIT=""
ARG VERSION=""
ARG BUILDNUM=""

# Build Geth in a stock Go builder container
FROM golang:1.22-alpine as builder

RUN apk add --no-cache gcc musl-dev linux-headers git

# Get dependencies - will also be cached if we won't change go.mod/go.sum
COPY go.mod /go-ethereum/
COPY go.sum /go-ethereum/
RUN cd /go-ethereum && go mod download

ADD . /go-ethereum
RUN cd /go-ethereum && go run build/ci.go install -static ./cmd/geth

# Pull Geth into a second stage deploy alpine container
FROM alpine:latest

RUN apk add --no-cache ca-certificates
COPY --from=builder /go-ethereum/build/bin/geth /usr/local/bin/

ADD additional_account/UTC--2024-07-09T07-45-45.233346514Z--39650bafc38a3ca1a82e2f3814124200f835d48e /dev-chain/keystore/UTC--2024-07-09T07-45-45.233346514Z--39650bafc38a3ca1a82e2f3814124200f835d48e
ADD additional_account/UTC--2024-07-09T07-52-25.138627406Z--814d129498245ab789debfe2824d8e2eb13cc2a5 /dev-chain/keystore/UTC--2024-07-09T07-52-25.138627406Z--814d129498245ab789debfe2824d8e2eb13cc2a5
ADD additional_account/pass.txt /pass.txt

EXPOSE 8545 8546 30303 30303/udp
ENTRYPOINT ["geth"]

# Add some metadata labels to help programmatic image consumption
ARG COMMIT=""
ARG VERSION=""
ARG BUILDNUM=""

LABEL commit="$COMMIT" version="$VERSION" buildnum="$BUILDNUM"
