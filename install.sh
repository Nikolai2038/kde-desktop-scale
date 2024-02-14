#!/bin/bash

# Exit on any error
set -e

# Dir with this script
dir="$(dirname "$(realpath "${BASH_SOURCE[0]}")")"

sudo ln -sf "${dir}/kde-scale.sh" /usr/bin/n2038-kde-scale

echo "Link created! Use command \"n2038-kde-scale\"." >&2
