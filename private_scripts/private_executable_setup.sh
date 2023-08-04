#!/bin/bash
set -Exeo pipefail
src=${1:-'git@codeberg.org:esperoj/dotfiles.git'}
cd "${HOME}"
mkdir -p ${HOME}/.local/{bin,share,lib,lib64}
mkdir -p "${HOME}/.ssh/sockets"

asdf_install() {
	set -- "$@"
	[[ $(command -v ${2-$1}) ]] && echo "The packages $1 is installed" && return
	asdf plugin add $1 $3
	asdf install $1 latest
	asdf global $1 latest
}
install_oh_my_zsh() {
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
}
setup_ssh(){
mkdir -p ~/.ssh
curl -sSfl "https://codeberg.org/esperoj/dotfiles/raw/branch/main/private_dot_ssh/encrypted_private_id_ed25519.asc" | gpg --passphrase "${ENCRYPTION_PASSPHRASE}" --batch -d >~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519
curl -sSfl "https://codeberg.org/esperoj/dotfiles/raw/branch/main/private_dot_ssh/private_known_hosts" >~/.ssh/known_hosts
}
export -f asdf_install install_oh_my_zsh

#Install packages on android
if [[ $(uname -o) = Android ]]; then
	apt-get update -qqy
	apt-get install -qqy 7zip aria2 chezmoi curl git jq mosh parallel rclone restic shfmt sqlite tmux vim wget gnupg zsh fzf openssh-client
	install_oh_my_zsh
	chezmoi init --apply --depth=1 --force --purge https://codeberg.org/esperoj/dotfiles.git
	chezmoi init --apply --ssh git@codeberg.org:esperoj/dotfiles.git
fi

if [[ $(uname -o) = *Linux* ]]; then
	# Install packages
	apt-get update -qqy
	apt-get install -qqy --no-install-recommends curl gnupg git unzip bzip2 wget dirmngr openssh-client
  setup_ssh
	# Install chezmoi and init the environment
  # Install asdf
	git clone --quiet --depth=1 https://github.com/asdf-vm/asdf.git ~/.asdf --branch master
  . "$HOME/.asdf/asdf.sh"
  # Install chezmoi
	asdf_install chezmoi
  # If the src is not a local path, then clone it and then change src to a local path
  [[ ! -d ${src} ]] && git clone --depth=1 --quiet ${src} .local/share/chezmoi  && src="${HOME}/.local/share/chezmoi"
  chezmoi init --apply "${src}"
	source .profile
	pkg-install.sh BASE apt-get install -qqy --no-install-recommends 7zip jq parallel python3 sqlite3 
	echo 'aria2 aria2c
rclone
restic' | xargs -I {} bash -c 'pkg-install.sh NET asdf_install {}'
	echo 'nodejs node
shfmt
shellcheck' | xargs -I {} bash -c 'pkg-install.sh DEV asdf_install {}'
	pkg-install.sh ALL apt-get install -qqy --no-install-recommends ffmpeg yt-dlp
	pkg-install.sh INTERACTIVE apt-get install -qqy --no-install-recommends vim tmux mosh zsh fzf
	pkg-install.sh INTERACTIVE install_oh_my_zsh
fi

ln -s $(command -v 7zz) "${HOME}/.local/bin/7z"
