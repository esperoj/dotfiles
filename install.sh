#!/bin/bash
# Install Bash-it
git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
~/.bash_it/install.sh --silent
# Install asdf plugins
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch master
. "$HOME/.asdf/asdf.sh"
# Add asdf plugins
plugins=(aria2 chezmoi doppler ffmpeg fzf jq nodejs poetry python shellcheck shfmt sqlite youtube-dl yq)
for plugin in "${plugins[@]}"
do
  echo installing "${plugin}"
  asdf plugin add "${plugin}"
  asdf install "${plugin}" latest
  asdf global "${plugin}" latest
done
# init chezmoi
chezmoi init --apply --promptString "passphrase=${ENCRYPTION_PASSPHRASE},hostname=${HOSTNAME}" https://codeberg.org/esperoj/dotfiles.git
