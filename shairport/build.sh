#!/bin/sh -ex
DIR=$( cd "$( dirname "$0" )" && pwd )
BUILD_DIR=${DIR}/../build/snap/shairport

mkdir -p ${BUILD_DIR}
cp -a /lib /usr ${BUILD_DIR}/
cp ${DIR}/shairport.sh ${DIR}/nqptp.sh ${BUILD_DIR}/
