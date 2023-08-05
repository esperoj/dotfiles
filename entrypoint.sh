#!/bin/bash
bash -c ". ${HOME}/.asdf/asdf.sh
chezmoi init --apply --force
source ${HOME}/.profile
${@}
"
