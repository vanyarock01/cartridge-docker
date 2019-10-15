#!/usr/bin/env bash

set -eu

# positional args
NAMESPACE=$1
DOCKER_DIR=$2

readarray -t images < <(docker images | grep $NAMESPACE/cartridge | awk '{print $1 ":" $2}')

for str in "${images[@]}"; do
   # pattern: namespace/repository:tag
   # to repository.tag
   filename=${str#*/}
   filename=${filename/:/.}
   docker save $str | gzip -2 > $DOCKER_DIR/$filename
done