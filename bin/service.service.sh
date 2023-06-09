#!/bin/bash -e

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
$DIR/wait-for-nqptp.sh
exec ${DIR}/../shairport/shairport.sh -c /var/snap/shairport/current/config/shairport.conf
