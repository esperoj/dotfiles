#!/bin/bash
set -Eeuxo pipefail
GIT_RAW_TEMPLATE=${GIT_RAW_TEMPLATE:-'${base:-https://codeberg.org}/${username:-esperoj}/${repo}/raw/branch/${branch:-main}/${path}'}

# Setup ssh
(
  mkdir -p ~/.ssh && cd "$_"
  curl -sSfl $(eval "(repo=dotfiles;path=private_dot_ssh/encrypted_private_id_ed25519.asc && printf ${GIT_RAW_TEMPLATE})") \
    | gpg -o id_ed25519 --passphrase "${ENCRYPTION_PASSPHRASE}" --batch -d
  chmod 600 id_ed25519
  curl -sSfl $(eval "(repo=dotfiles;path=private_dot_ssh/private_known_hosts && printf ${GIT_RAW_TEMPLATE})") >known_hosts
)

# Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin

# Init chezmoi
chezmoi init --apply --promptString "passphrase=${ENCRYPTION_PASSPHRASE},hostname=${HOSTNAME}" --ssh git@codeberg.org:esperoj/dotfiles.git
