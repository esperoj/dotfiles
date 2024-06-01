#!/bin/bash
set -Eueo pipefail
cd "${HOME}"
# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ".local/bin"
# Clone dotfiles
chezmoi_path=".local/share/chezmoi"
(
  mkdir -p "${chezmoi_path}"
  cd "${chezmoi_path}"
  git clone --depth=1 https://codeberg.org/esperoj/dotfiles.git .
  git remote set-url origin git@codeberg.org:esperoj/dotfiles.git
)
# Post setup
ln -s "${chezmoi_path}/bin" .
ln -s "${chezmoi_path}/esperoj-scripts" .
