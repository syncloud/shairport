#!/bin/bash -e
DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

./deps.sh
py.test -x -s "$1" --distro="$2" --ver="$DRONE_BUILD_NUMBER" --app=shairport
