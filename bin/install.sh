#!/bin/bash
set -Euxeo pipefail
# Install chezmoi
path="${HOME}/.local/bin"
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${path}"
"${path}/chezmoi" init --apply https://codeberg.org/esperoj/dotfiles.git
