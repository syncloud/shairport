#!/bin/sh -ex

DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}
BUILD_DIR=${DIR}/../build/snap/shareport
docker build --build-arg VERSION=$1 -t syncloud .
docker create --name=syncloud syncloud
mkdir -p ${BUILD_DIR}
cd ${BUILD_DIR}
docker export syncloud -o syncloud.tar
tar xf syncloud.tar
rm -rf syncloud.tar
