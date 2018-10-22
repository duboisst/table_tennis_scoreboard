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
echo
cd "$__dir"
docker build -t sds/score:latest .

 