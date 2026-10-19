#!/bin/bash -xe
DIR=$( cd "$( dirname "$0" )" && pwd )
BUILD=${DIR}/../build/snap/shairport

${BUILD}/shairport.sh -V | grep AirPlay2
