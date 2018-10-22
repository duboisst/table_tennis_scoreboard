#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

docker run -it --rm \
    -v d:/workspace/gtk:/score \
    -e DISPLAY=192.168.0.120:0.0 \
    sds/score "$@"
