#!/bin/bash
set -Eueo pipefail
cd ~
# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ".local/bin"
# Clone dotfiles
path=".local/share/chezmoi"
(
  mkdir -p "${path}"
  cd "${path}"
  git clone --depth=1 https://codeberg.org/esperoj/dotfiles.git .
  git remote set-url origin git@codeberg.org:esperoj/dotfiles.git
)
# Post setup
ln -s "${path}/bin" .
