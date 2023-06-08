#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && cd .. && pwd )
exec ${DIR}/shairport/shairport.sh -c /var/snap/shairport/current/config/shairport.conf
