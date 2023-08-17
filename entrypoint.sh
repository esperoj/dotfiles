#!/bin/bash
. ${HOME}/.asdf/asdf.sh
chezmoi init --apply --force
bash -s <<EOL
source ~/.profile || exit 1
${1}
EOL
