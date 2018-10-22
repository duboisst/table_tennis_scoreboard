#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo
echo "Building local Sanofi cable-indexer image"
echo "-----------------------------------------"
echo
echo "Context: $__dir"
echo "Proxy:   $http_proxy"
echo
cd "$__dir"
docker build --build-arg http_proxy="http://$http_proxy" --build-arg https_proxy="http://$http_proxy" -t sds/score:latest .

 