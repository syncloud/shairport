#!/bin/bash -e
DIR=$( cd "$( dirname "$0" )" && pwd )
cd ${DIR}

for i in $(seq 1 10); do
  apt-get update && apt-get install -y sshpass openssh-client wget && break
  echo "retry apt"
  sleep 5
done

pip install -r requirements.txt
