#!/bin/bash -xe
DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

HOOKS=${DIR}/../build/snap/meta/hooks
BIN=${DIR}/../build/snap/bin
mkdir -p ${HOOKS} ${BIN}

go test ./...

CGO_ENABLED=0 go build -o ${HOOKS}/install ./cmd/install
CGO_ENABLED=0 go build -o ${HOOKS}/configure ./cmd/configure
CGO_ENABLED=0 go build -o ${HOOKS}/pre-refresh ./cmd/pre-refresh
CGO_ENABLED=0 go build -o ${HOOKS}/post-refresh ./cmd/post-refresh
CGO_ENABLED=0 go build -o ${BIN}/cli ./cmd/cli
