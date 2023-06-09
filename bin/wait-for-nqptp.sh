#!/bin/bash -e
for _ in $(seq 10); do
    echo > /dev/tcp/localhost/320 && exit 0
    echo "waiting for nqptp"
    sleep 1
done