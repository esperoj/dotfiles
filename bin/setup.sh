#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export PATH="${HOME}/bin:${HOME}/.local/bin:${PATH}"
OS="$(uname -o)"

cd "${HOME}"
mkdir -p "${HOME}/.local"/{bin,share,lib,lib64}

install_apt_packages() {
  local packages=$(echo "
    aria2
    exiftool
    iputils-ping
    lsb-release
    openssh-server
    python3
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
  uv
  ')
  install.sh ${packages}
}

setup_linux() {
  set -Exeo pipefail
  parallel --keep-order -vj0 {} <<EOL
  install_packages
  install_apt_packages
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
