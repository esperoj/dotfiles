#!/bin/bash
set -Euxeo pipefail
# Install chezmoi
path="${HOME}/.local/bin"
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${path}"
# Init chezmoi
"${path}/chezmoi" init https://codeberg.org/esperoj/dotfiles.git
cd "${HOME}/.local/share/chezmoi"
git remote set-url origin git@codeberg.org:esperoj/dotfiles.git
