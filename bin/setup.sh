#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export PATH="${HOME}/bin:${HOME}/.local/bin:${PATH}"
cmds=$(echo '
  install_7zip
  install_kopia
  install_oh_my_zsh
  install_packages
  install_rclone
  install_restic
  install_woodpecker_cli
  ' | xargs)

cd "${HOME}"

install_7zip() {
  pkg-install.sh BASE bin "https://7-zip.org/a/7z2301-linux-%arch:x86_64=x64:aarch64=arm64%.tar.xz" 7zz
}

install_kopia() {
  pkg-install.sh DISABLED ghbin kopia/kopia "-linux-%arch:x86_64=x64:aarch64=arm64%.tar.gz$" kopia
}

install_oh_my_zsh() {
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh BASE)" "" --RUNZSH=no --CHSH=yes
}

install_packages() {
  packages="
    aria2
    lsb-release
    inxi
    nodejs
    npm
    shfmt
    sudo
    time
  "
  xargs apt install -qqy --no-install-recommends <<<"${packages}"
}

install_rclone() {
  pkg-install.sh BASE ghbin rclone/rclone "-linux-%arch:x86_64=amd64:aarch64=arm64%.zip$" "rclone-*/rclone"
}

install_restic() {
  pkg-install.sh BASE ghbin restic/restic "_linux_%arch:x86_64=amd64:aarch64=arm64%.bz2$" restic
}

install_woodpecker_cli() {
  pkg-install.sh BASE ghbin woodpecker-ci/woodpecker "woodpecker-cli_linux_%arch:x86_64=amd64:aarch64=arm64%.tar.gz$" woodpecker-cli
}

setup() {
  set -Euxeo pipefail
  apt update -y
  apt install -qqy --no-install-recommends \
    jq parallel zsh

  parallel --keep-order -vj0 ::: ${cmds}

  ln -s $(command -v 7zz) ".local/bin/7z"
  ln -s $(command -v python3) ".local/bin/python"
  mkdir -p ".ssh/sockets"
}

export -f ${cmds}

setup
