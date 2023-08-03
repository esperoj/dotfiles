#!/bin/bash
set -Eeuo pipefail
cd "${HOME}"
mkdir -p ${HOME}/{.local/,}bin
OS=$(uname -o)
init_chezmoi() {
	chezmoi init --apply --depth=1 --force --purge https://codeberg.org/esperoj/dotfiles.git
	chezmoi init --apply --ssh git@codeberg.org:esperoj/dotfiles.git
}
asdf_install(){
  set -- "$@"
  [[ $(command -v ${2-$1}) ]] && echo "The packages $1 is installed" && return
  asdf plugin add $1 $3
  asdf install $1 latest
  asdf global $1 latest
}
install_oh_my_zsh(){
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}
export -f asdf_install
if [[ $OS = Android ]]; then
	apt update -qy
	apt install -qy 7zip aria2 chezmoi curl git jq mosh parallel rclone restic shfmt sqlite tmux vim wget gnupg
  init_chezmoi
	exit
fi

pkg-install.sh BASE apt-get install -qy --no-install-recommends 7zip curl dirmngr git gnupg jq parallel python3 sqlite3 wget
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch master
. "$HOME/.asdf/asdf.sh"
echo 'chezmoi' | xargs -I {} bash -c 'pkg-install.sh BASE asdf_install {}'
init_chezmoi
source .profile
echo 'aria2 aria2c
rclone
restic' | xargs -I {} bash -c 'pkg-install.sh NET asdf_install {}'
echo 'nodejs node
shfmt
shellcheck' | xargs -I {} bash -c 'pkg-install.sh DEV asdf_install {}'
pkg-install.sh INTERACTIVE apt-get install -qy --no-install-recommends vim tmux mosh zsh
pkg-install.sh INTERACTIVE install_oh_my_zsh
pkg-install.sh ALL apt-get install -qy --no-install-recommends ffmpeg yt-dlp
