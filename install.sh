#!/bin/bash
set -Eeuxo pipefail
GIT_RAW_TEMPLATE=${GIT_RAW_TEMPLATE:-'${base:-https://codeberg.org}/${username:-esperoj}/${repo}/raw/branch/${branch:-main}/${path}'}

# Install Bash-it
git clone --depth 1 --filter=blob:none https://github.com/Bash-it/bash-it.git ~/.bash_it
~/.bash_it/install.sh --silent

# Install fzf
git clone --depth 1 --filter=blob:none https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --no-zsh --no-fish --all

# Setup ssh
(
  mkdir -p ~/.ssh && cd "$_"
  curl -sSfl $(eval "(repo=dotfiles;path=private_dot_ssh/encrypted_private_id_ed25519.asc && printf ${GIT_RAW_TEMPLATE})") \
    | gpg --passphrase "${ENCRYPTION_PASSPHRASE}" --batch -d\
    >id_ed25519
  chmod 600 id_ed25519
  curl -sSfl $(eval "(repo=dotfiles;path=private_dot_ssh/private_known_hosts && printf ${GIT_RAW_TEMPLATE})") >known_hosts
)

# Install asdf
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch master

# shellcheck source=/dev/null
source "${HOME}/.asdf/asdf.sh"

# Add asdf plugins
plugins=(chezmoi doppler python nodejs)
for plugin in "${plugins[@]}"; do
  echo Installing plugin "${plugin}"
  asdf plugin add "${plugin}"
  asdf install "${plugin}" latest
  asdf global "${plugin}" latest
done

# Init chezmoi
chezmoi init --apply --promptString "passphrase=${ENCRYPTION_PASSPHRASE},hostname=${HOSTNAME}" --ssh git@codeberg.org:esperoj/dotfiles.git
