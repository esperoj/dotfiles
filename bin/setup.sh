#!/bin/bash
set -eux
export DEBIAN_FRONTEND=noninteractive
export PATH="${HOME}/bin:${HOME}/.local/bin:${PATH}"
if [ "$(id -u)" -eq 0 ]; then
  export SUDO_COMMAND=""
else
  export SUDO_COMMAND="sudo"
fi

packages=""

base_packages="
  7zip
  ca-certificates
  caddy
  curl
  dotfiles
  gnupg
  git
  filen
  jq
  openssh-client
  parallel
  python3
  rclone
  screen
  sq
  sudo
  time
  tzdata
  unzip
  uv
  wget
  xz-utils"

main_packages="
  aria2
  exiftool
  ffmpeg
  iputils-ping
  rename
  openssh-server
  task
  yt_dlp
"

dev_packages="
  fzf
  nodejs
  npm
  oh_my_zsh
  shfmt
  tmux
  vim
  zsh
"

termux_packages="
  aria2
  exiftool
  fzf
  gnupg
  git
  inetutils
  jq
  openssh
  p7zip
  parallel
  rclone
  screen
  time
  tmux
  unzip
  vim
  wget
  xz-utils
  zsh"

ct8_packages="
  caddy
  dotfiles
  fzf
  oh_my_zsh
  pipx
  rclone
  task
"

cd "${HOME}"

before() {
  mkdir -p ".local"/{bin,share,lib,lib64,opt}
}

after() {
  echo Nothing
}

before
case "$1" in
ct8)
  install.sh $(echo "${ct8_packages}")
  ;;
docker_base)
  $SUDO_COMMAND apt-get install -q=2 --no-install-recommends ca-certificates curl gnupg git jq openssh-client parallel sq sudo unzip wget xz-utils
  install.sh $(echo "${base_packages}")
  install.sh esperoj
  ;;
docker_main)
  install.sh $(echo "${main_packages}")
  ;;
docker_dev)
  install.sh $(echo "${dev_packages}")
  ;;
termux)
  apt-get update -o "Acquire::https::Verify-Peer=false" --allow-unauthenticated -y
  apt-get install -o "Acquire::https::Verify-Peer=false" --allow-unauthenticated -y --no-install-recommends $(echo "${termux_packages}")
  install.sh oh_my_zsh
  chsh -s $(which zsh)
  termux-setup-storage
  . ~/.profile
  (
    cd /sdcard
    git clone --depth=1 https://github.com/esperoj/notebook.git
    (
      cd notebook
      git remote set-url origin git@github.com:esperoj/notebook.git
      git remote set-url origin --push --add git@github.com:esperoj/notebook.git
      git remote set-url origin --push --add git@codeberg.org:esperoj/notebook.git
    )
    rclone sync -v workspace-0: workspace
    rclone sync -v backup-0: backup
    rclone bisync -v --resync ./workspace workspace-0:
    rclone bisync -v --resync ./backup backup-0:
  )
  ;;
esac
after
