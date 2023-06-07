#!/bin/bash -xe
DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
LIBS=$LIBS:$(echo ${DIR}/lib)
LIBS=$LIBS:$(echo ${DIR}/usr/lib)
LIBS=$LIBS:$(echo ${DIR}/usr/lib/engines-3)
LIBS=$LIBS:$(echo ${DIR}/usr/lib/libv4l)
LIBS=$LIBS:$(echo ${DIR}/usr/lib/libv4l/plugins)
LIBS=$LIBS:$(echo ${DIR}/usr/lib/ossl-modules)
LIBS=$LIBS:$(echo ${DIR}/usr/lib/pulseaudio)
LIBS=$LIBS:$(echo ${DIR}/usr/lib/vdpau)
LIBS=$LIBS:$(echo ${DIR}/usr/local/lib)

exec ${DIR}/lib/ld-musl-*.so* --library-path $LIBS ${DIR}/usr/local/bin/shairport-sync "$@"
