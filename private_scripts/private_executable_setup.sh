#!/bin/bash
set -Eeuo pipefail

cd "${HOME}"
mkdir -p ${HOME}/{.local/,}bin
mkdir -p "${HOME}/.ssh/sockets"

asdf_install() {
	set -- "$@"
	[[ $(command -v ${2-$1}) ]] && echo "The packages $1 is installed" && return
	asdf plugin add $1 $3
	asdf install $1 latest
	asdf global $1 latest
}
install_oh_my_zsh() {
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
}
export -f asdf_install install_oh_my_zsh

if [[ $(uname -o) = Android ]]; then
	apt update -qy
	apt install -qy 7zip aria2 chezmoi curl git jq mosh parallel rclone restic shfmt sqlite tmux vim wget gnupg zsh fzf openssh-client
	install_oh_my_zsh
	chezmoi init --apply --depth=1 --force --purge https://codeberg.org/esperoj/dotfiles.git
	chezmoi init --apply --ssh git@codeberg.org:esperoj/dotfiles.git
fi

if [[ $(uname -o) = *Linux* ]]; then
	# Install packages
	apt update -qy
	apt-get install -qy --no-install-recommends 7zip curl dirmngr git gnupg jq parallel python3 sqlite3 wget unzip bzip2

	# Install chezmoi and init the environment
	sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin"
	$HOME/.local/bin/chezmoi init --one-shot https://codeberg.org/esperoj/dotfiles.git
	git clone --quiet --depth=1 https://github.com/asdf-vm/asdf.git ~/.asdf --branch master
	source .profile
	echo 'chezmoi' | xargs -I {} bash -c 'pkg-install.sh BASE asdf_install {}'
	echo 'aria2 aria2c
rclone
restic' | xargs -I {} bash -c 'pkg-install.sh NET asdf_install {}'
	echo 'nodejs node
shfmt
shellcheck' | xargs -I {} bash -c 'pkg-install.sh DEV asdf_install {}'
	pkg-install.sh ALL apt-get install -qy --no-install-recommends ffmpeg yt-dlp
	pkg-install.sh INTERACTIVE apt-get install -qy --no-install-recommends vim tmux mosh zsh fzf
	pkg-install.sh INTERACTIVE install_oh_my_zsh

	# Reinit with ssh
	chezmoi init --apply --ssh git@codeberg.org:esperoj/dotfiles.git
fi

ln -s $(command -v 7zz) "${HOME}/.local/bin/7z"
