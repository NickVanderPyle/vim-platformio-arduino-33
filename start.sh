#!/bin/bash

if [ $# -ne 1 ]; then
  echo 1>&2 "Usage: $0 <path to load as default /app dir in container>"
  exit 3
fi

abspath() {                                               
    cd "$(dirname "$1")"
    printf "%s/%s\n" "$(pwd)" "$(basename "$1")"
}

fullpath=$(abspath $1)

docker run \
  --rm \
  -v ${fullpath}:/app \
  -it $(docker build \
            -q \
            --build-arg USERNAME=${USER} \
            --build-arg USER_UID=$(id -u ${USER}) \
            --build-arg USER_GID=$(id -g ${USER}) \
            -f ./.devcontainer/Dockerfile \
            .)