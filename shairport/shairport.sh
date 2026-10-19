#!/bin/bash -e
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
LIBS=$(echo ${DIR}/lib)
LIBS=$LIBS:$(echo ${DIR}/usr/lib)
LIBS=$LIBS:$(echo ${DIR}/usr/lib/engines-3)
LIBS=$LIBS:$(echo ${DIR}/usr/lib/ossl-modules)
LIBS=$LIBS:$(echo ${DIR}/usr/lib/pulseaudio)
LIBS=$LIBS:$(echo ${DIR}/usr/local/lib)

exec ${DIR}/lib/ld-musl-*.so* --library-path $LIBS ${DIR}/usr/local/bin/shairport-sync "$@"
