#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export PATH="${HOME}/bin:${HOME}/.local/bin:${PATH}"
OS="$(uname -o)"
cmds=$(echo '
  install_7zip
  echo install_asdf_packages
  install_caddy
  install_fzf
  install_esperoj
  install_kopia
  install_oh_my_zsh
  install_packages
  install_pipx
  install_rclone
  install_restic
  install_shfmt
  install_task
  install_woodpecker_cli
  ')

cd "${HOME}"
mkdir -p ${HOME}/.local/{bin,share,lib,lib64}

install_7zip() {
  install.sh BASE bin "https://7-zip.org/a/7z2301-linux-%arch:x86_64=x64:aarch64=arm64%.tar.xz" 7zz
}

install_asdf_packages() {
  # TODO: Update asdf version yearly
  git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
  . "${HOME}/.asdf/asdf.sh"
  asdf_install() {
    asdf plugin add $1
    asdf install $1 latest
    asdf global $1 latest
  }
  export -f asdf_install
  local packages="fzf nodejs"
  parallel --keep-order -vj1 asdf_install ::: ${packages}
}

install_caddy() {
  install.sh BASE ghbin caddyserver/caddy "linux_%arch:x86_64=amd64:aarch64=arm64%.tar.gz$" "caddy"
}

install_fzf() {
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --key-bindings --completion --no-update-rc
}

install_esperoj() {
  install.sh BASE ghbin esperoj/esperoj "^esperoj_linux_%arch:x86_64=x86_64%$" esperoj
}

install_kopia() {
  install.sh DISABLED ghbin kopia/kopia "-linux-%arch:x86_64=x64:aarch64=arm64%.tar.gz$" kopia
}

install_oh_my_zsh() {
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh BASE)" "" --RUNZSH=no --CHSH=yes
}

install_packages() {
  packages=$(echo "
    aria2
    exiftool
    iputils-ping
    lsb-release
    nodejs
    openssh-server
    screen
    time
    tmux
    vim
    zstd
  ")
  sudo apt install -qqy --no-install-recommends ${packages}
}

install_pipx() {
  install.sh BASE ghbin pypa/pipx pipx.pyz pipx
  # pipx install git+https://github.com/esperoj/esperoj.git
  pipx install poetry
}

install_rclone() {
  install.sh BASE ghbin rclone/rclone "-linux-%arch:x86_64=amd64:aarch64=arm64%.zip$" "rclone-*/rclone"
}

install_restic() {
  install.sh DISABLED ghbin restic/restic "_linux_%arch:x86_64=amd64:aarch64=arm64%.bz2$" restic
}

install_shfmt() {
  install.sh BASE ghbin mvdan/sh "_linux_%arch:x86_64=amd64:aarch64=arm64%$" shfmt
}

install_task() {
  sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin
}

install_yt_dlp() {
  install.sh DISABLED ghbin yt-dlp/yt-dlp "_linux%arch:x86_64=:aarch64=_aarch64%$" yt-dlp
}

install_woodpecker_cli() {
  install.sh DISABLED ghbin woodpecker-ci/woodpecker "woodpecker-cli_linux_%arch:x86_64=amd64:aarch64=arm64%.tar.gz$" woodpecker-cli
}

setup_android() {
  sudo apt-get update -qqy
  sudo apt-get upgrade -qqy
  sudo apt-get install -qqy 7zip aria2 chezmoi curl git jq mosh parallel rclone restic shfmt sqlite tmux vim wget gnupg zsh fzf termux-api
  install_oh_my_zsh
  termux-setup-storage
  termux-change-repo
}

setup_linux() {
  set -Euxeo pipefail
  parallel --keep-order -vj0 ::: ${cmds}
}

export -f ${cmds}
case "${OS,,}" in
*android*)
  setup_android
  ;;
*linux*)
  setup_linux
  ;;
esac
ln -s $(command -v 7zz) ".local/bin/7z"
ln -s $(command -v python3) ".local/bin/python"
mkdir -p ".ssh/sockets" ".sockets"
rm -rf .cache
