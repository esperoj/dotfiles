#!/bin/bash
set -Euxeo pipefail

export DEBIAN_FRONTEND=noninteractive
export PATH="${HOME}/bin:${PATH}"
cd "${HOME}"

install_packages() {
  packages="
    aria2
    7zip
    jq
    lsb-release
    inxi
    nodejs
    npm
    rclone
    restic
    shfmt
    sudo
    time
  "
  xargs apt-get install -y --no-install-recommends <<<"${packages}"
}

install_oh_my_zsh() {
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --RUNZSH=no --CHSH=yes
}

install_woodpecker_cli() {
  curl -fsLs https://github.com/woodpecker-ci/woodpecker/releases/latest/download/woodpecker-cli_linux_amd64.tar.gz | tar zx -C .local/bin
}

post_setup() {
  ln -s $(command -v 7zz) ".local/bin/7z"
  ln -s $(command -v python3) ".local/bin/python"
  mkdir -p ".ssh/sockets"
}

cmds="install_packages
  install_oh_my_zsh
  install_woodpecker_cli"

export -f $(echo -n "${cmds}" | tr "\n" " ")

apt-get update -y
apt-get install -y --no-install-recommends \
  parallel zsh

parallel --keep-order -vj0 {} <<<"${cmds}"
post_setup
