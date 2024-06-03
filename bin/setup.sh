#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export PATH="${HOME}/bin:${HOME}/.local/bin:${PATH}"
OS="$(uname -o)"

cd "${HOME}"
mkdir -p ${HOME}/.local/{bin,share,lib,lib64}

install_asdf_packages() {
  install.sh asdf
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

install_apt_packages() {
  local packages=$(echo "
    aria2
    exiftool
    iputils-ping
    lsb-release
    nodejs
    npm
    openssh-server
    python3-full
    python3-pip 
    screen
    time
    tmux
    vim
    zstd
  ")
  sudo apt-get update -qqy
  sudo apt-get install -qqy --no-install-recommends ${packages}
}

install_packages() {
  local packages=$(echo '
  7zip
  caddy
  fzf
  esperoj
  oh_my_zsh
  rclone
  shfmt
  task
  ')
  install.sh ${packages}
}

setup_linux() {
  set -Exeo pipefail
  parallel --keep-order -vj0 {} <<EOL
  install_apt_packages
  install_packages
EOL
}

export -f $(compgen -A function)

case "${OS,,}" in
*linux*)
  setup_linux
  ;;
esac

ln -s $(command -v 7zz) ".local/bin/7z"
ln -s $(command -v python3) ".local/bin/python"
mkdir -p ".ssh/sockets" ".sockets"
