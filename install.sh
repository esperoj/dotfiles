#!/bin/bash

# Install Bash-it
git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
~/.bash_it/install.sh --silent

# Setup ssh
mkdir -p ~/.ssh
curl -sSfl "https://codeberg.org/esperoj/dotfiles/raw/branch/main/private_dot_ssh/encrypted_private_id_ed25519.asc" | gpg --passphrase "${ENCRYPTION_PASSPHRASE}" --batch -d >~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519
curl -sSfl "https://codeberg.org/esperoj/dotfiles/raw/branch/main/private_dot_ssh/private_known_hosts" >~/.ssh/known_hosts

# Install asdf
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch master

# shellcheck source=/dev/null
source "${HOME}/.asdf/asdf.sh"

# Add asdf plugins
plugins=(aria2 chezmoi doppler ffmpeg jq python nodejs sqlite yq)
for plugin in "${plugins[@]}"; do
  echo Installing plugin "${plugin}"
  asdf plugin add "${plugin}"
  asdf install "${plugin}" latest
  asdf global "${plugin}" latest
done

# Init chezmoi
chezmoi init --apply --promptString "passphrase=${ENCRYPTION_PASSPHRASE},hostname=${HOSTNAME}" --ssh git@codeberg.org:esperoj/dotfiles.git
