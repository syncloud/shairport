#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )
exec ${DIR}/shairport/usr/local/bin/shairport-sync 
