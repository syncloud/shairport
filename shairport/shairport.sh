#!/bin/bash -xe
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
LIBS=$(echo ${DIR}/lib/*-linux-gnu*)
LIBS=$LIBS:$(echo ${DIR}/usr/lib/*-linux-gnu*)
LIBS=$LIBS:$(echo ${DIR}/usr/lib)
LIBS=$LIBS:$(echo ${DIR}/usr/local/lib)
exec ${DIR}/lib/*-linux*/ld-*.so --library-path $LIBS ${DIR}/usr/local/bin/shairport-sync "$@"
