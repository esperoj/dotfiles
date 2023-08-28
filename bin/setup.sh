#!/bin/bash
set -Euxeo pipefail
export DEBIAN_FRONTEND=noninteractive
cd "${HOME}"
mkdir -p ".local/bin/"

install-dotfiles() {
  curl -fsLS https://codeberg.org/esperoj/dotfiles/raw/branch/main/bin/install-dotfiles.sh | bash
}

install-packages() {
  packages="
    7zip
    jq
    inxi
    nodejs
    npm
    rclone
    restic
    shfmt
    sudo
    time
  "
  xargs apt-fast install -y --no-install-recommends <<<"${packages}"
}

install_oh_my_zsh() {
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --RUNZSH=no --CHSH=yes
}

post-setup() {
  ln -s ".local/share/chezmoi/bin" .
  ln -s $(command -v 7zz) ".local/bin/7z"
  ln -s $(command -v python3) ".local/bin/python"
  mkdir -p ".ssh/sockets"
}

export -f install-dotfiles install-packages install_oh_my_zsh

apt-get update -y
# apt-get upgrade -y
apt-get install -y --no-install-recommends \
  aria2 parallel zsh

# Install apt-fast
/bin/bash -c "$(curl -sL https://git.io/vokNn)"

parallel --keep-order -vj0 {} <<EOL
install-dotfiles
install-packages
install_oh_my_zsh
curl -fsLs https://github.com/woodpecker-ci/woodpecker/releases/latest/download/woodpecker-cli_linux_amd64.tar.gz | tar zx -C .local/bin
EOL

post-setup
