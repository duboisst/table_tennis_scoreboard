#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

docker run -it --rm \
    -v d:/workspace/table_tennis_scoreboard:/score \
    -e DISPLAY=192.168.0.124:0.0 \
    sds/score "$@"
