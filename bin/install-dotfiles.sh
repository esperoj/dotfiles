#!/bin/bash
set -Eueo pipefail
# Install chezmoi
path="${HOME}/.local/bin"
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${path}"
# Clone dotfiles
mkdir -p "${HOME}/.local/share/chezmoi"
cd "${HOME}/.local/share/chezmoi"
git clone --depth=1 https://codeberg.org/esperoj/dotfiles.git .
git remote set-url origin git@codeberg.org:esperoj/dotfiles.git
