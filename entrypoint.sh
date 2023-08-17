#!/bin/bash
echo "Running entrypoint.sh"
. ${HOME}/.asdf/asdf.sh
chezmoi init --apply --force
source ${HOME}/.profile
eval ${1@Q}
