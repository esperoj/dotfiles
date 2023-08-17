#!/bin/bash
echo "Running entrypoint.sh"
set -x
. ${HOME}/.asdf/asdf.sh
chezmoi init --apply --force
source ${HOME}/.profile
eval $1
