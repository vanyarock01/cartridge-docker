#!/usr/bin/env bash

set -eu

# positional args
NAMESPACE=$1
DOCKER_DIR=$2

for filepath in $DOCKER_DIR/*; do
    filename=$(basename $filepath)
    reponame=$( cut -d '.' -f 2- <<< "$filename" )
    tagname=$( cut -d '.' -f 1 <<< "$filename" )
    zcat $DOCKER_DIR/$filename | docker import - "$NAMESPACE/$reponame:$tagname"
done