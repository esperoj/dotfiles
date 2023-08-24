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
    aria2
    ffmpeg
    jq
    lsb-release
    nodejs
    rclone
    restic
    shfmt
    sudo
    time
    yt-dlp
    zsh
  "
  xargs apt-get install -y --no-install-recommends <<<"${packages}"
}

install_oh_my_zsh(){
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
apt-get install -y --no-install-recommends parallel

parallel --keep-order -vj0 {} <<EOL
install-dotfiles
install-packages
install_oh_my_zsh
curl -fsLS https://github.com/harness/drone-cli/releases/latest/download/drone_linux_amd64.tar.gz | tar zx -C .local/bin
EOL

post-setup
