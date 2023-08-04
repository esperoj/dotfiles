#!/bin/bash
set -Eeo pipefail
cd "${HOME}"

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
setup_ssh() {
	mkdir -p ~/.ssh
	curl -sSfl "https://codeberg.org/esperoj/dotfiles/raw/branch/main/private_dot_ssh/encrypted_private_id_ed25519.asc" | gpg --passphrase "${ENCRYPTION_PASSPHRASE}" --batch -d >~/.ssh/id_ed25519
	chmod 600 ~/.ssh/id_ed25519
	curl -sSfl "https://codeberg.org/esperoj/dotfiles/raw/branch/main/private_dot_ssh/private_known_hosts" >~/.ssh/known_hosts
	mkdir -p "${HOME}/.ssh/sockets"
}

clone() {
	local src dest
	src=${1:-'git@codeberg.org:esperoj/dotfiles.git'}
	dest=${2:-'.local/share/chezmoi'}
	setup_ssh
	git clone --depth=1 --quiet ${src} ${dest}
}

export -f asdf_install install_oh_my_zsh

#Install packages on android
install() {
	mkdir -p ${HOME}/.local/{bin,share,lib,lib64}
	if [[ $(uname -o) = Android ]]; then
		apt-get update -qqy
		apt-get install -qqy 7zip aria2 chezmoi curl git jq mosh parallel rclone restic shfmt sqlite tmux vim wget gnupg zsh fzf openssh-client
		install_oh_my_zsh
		chezmoi init --apply --depth=1 --force --purge https://codeberg.org/esperoj/dotfiles.git
		chezmoi init --apply --ssh git@codeberg.org:esperoj/dotfiles.git
		termux-setup-storage
		termux-change-repo
	fi

	[[ $(uname -o) = *Linux* ]] && {
		# Install packages
		apt-get update -qqy
		apt-get install -qqy --no-install-recommends curl gnupg git unzip bzip2 wget dirmngr openssh-client ca-certificates
		# Install asdf
		git clone --quiet --depth=1 https://github.com/asdf-vm/asdf.git ~/.asdf --branch master
		. "$HOME/.asdf/asdf.sh"
		# Install chezmoi
		asdf_install chezmoi
		pkg-install.sh BASE apt-get install -qqy --no-install-recommends 7zip jq parallel python3 sqlite3
		echo 'aria2 aria2c,rclone,restic' | tr "," "\n" | xargs -I {} bash -c 'pkg-install.sh NET asdf_install {}'
		echo 'nodejs node,shfmt,shellcheck' | tr "," "\n" | xargs -I {} bash -c 'pkg-install.sh DEV asdf_install {}'
		pkg-install.sh ALL apt-get install -qqy --no-install-recommends ffmpeg yt-dlp
		pkg-install.sh INTERACTIVE apt-get install -qqy --no-install-recommends vim tmux mosh zsh fzf
		pkg-install.sh INTERACTIVE install_oh_my_zsh
  }
}

[[ "$1" == clone ]] && {
	shift 1
	clone "$@"
	#ln -s $(chezmoi source-path)/scripts .
	exit
}
[[ "$1" == install ]] && {
	shift 1
	install "$@"
	#ln -s $(command -v 7zz) ".local/bin/7z"
	exit
}
