#!/bin/bash
set -Eeuxo pipefail

# Install chezmoi
mkdir -p "${HOME}/.local/bin"
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${HOME}/.local/bin"

# Init chezmoi
chezmoi init --apply --depth=1 --force --purge https://codeberg.org/esperoj/dotfiles.git
chezmoi init --apply --ssh git@codeberg.org:esperoj/dotfiles.git
