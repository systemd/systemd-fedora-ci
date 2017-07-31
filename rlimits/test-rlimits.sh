#!/bin/bash

set -x
set -e
set -o pipefail

[[ "$(ulimit -n -S)" = "10000" ]]
[[ "$(ulimit -n -H)" = "16384" ]]

touch /var/run/testok
