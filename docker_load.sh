#!/usr/bin/env bash

set -eu

# positional args
DOCKER_DIR=$1

for filepath in $DOCKER_DIR/*; do
    filename=$(basename $filepath)
    reponame=$( cut -d '.' -f 2- <<< "$filename" )
    tagname=$( cut -d '.' -f 1 <<< "$filename" )
    zcat $DOCKER_DIR/$filename | docker import - "$reponame:$tagname"
done