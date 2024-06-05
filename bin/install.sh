#!/bin/bash

OS="$(uname -o)"

install_7zip() {
  pkg-install.sh bin "https://7-zip.org/a/7z2301-linux-%arch:x86_64=x64:aarch64=arm64%.tar.xz" 7zz
}

install_asdf() {
  git clone --depth 1 https://github.com/asdf-vm/asdf.git ~/.asdf --branch master
  . "${HOME}/.asdf/asdf.sh"
}

install_caddy() {
  pkg-install.sh ghbin caddyserver/caddy "linux_%arch:x86_64=amd64:aarch64=arm64%.tar.gz$" "caddy"
}

# Install chezmoi and the dotfiles and apply if $APPLY is true
install_dotfiles() {
  set -Eeo pipefail
  if [[ $- == *i* ]]; then
    if [ -z "${ENCRYPTION_PASSPHRASE}"]; then
      echo "Please enter your encryption passphrase:"
      read -s ENCRYPTION_PASSPHRASE
      export ENCRYPTION_PASSPHRASE="${ENCRYPTION_PASSPHRASE}"
    fi
    if [ -z "${MACHINE_NAME}"]; then
      echo "Please enter your machine name:"
      read -s MACHINE_NAME
    fi
  fi
  export MACHINE_NAME=${MACHINE_NAME-segfault}
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ".local/bin"
  chezmoi_path=".local/share/chezmoi"
  mkdir -p "${chezmoi_path}"
  (
    cd "${chezmoi_path}"
    git clone --depth=1 https://codeberg.org/esperoj/dotfiles.git .
    git remote set-url origin git@codeberg.org:esperoj/dotfiles.git
  )
  ln -s "${chezmoi_path}"/{bin,esperoj-scripts,taskfiles,Taskfile.yml} .
  if [[ $APPLY == "true" ]]; then
    ./.local/bin/chezmoi init --apply --force
  fi
}

install_fzf() {
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --key-bindings --completion --no-update-rc
}

install_esperoj() {
  pkg-install.sh ghbin esperoj/esperoj "^esperoj_linux_%arch:x86_64=x86_64%$" esperoj
}

install_kopia() {
  pkg-install.sh ghbin kopia/kopia "-linux-%arch:x86_64=x64:aarch64=arm64%.tar.gz$" kopia
}

install_oh_my_zsh() {
  curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash -s -- --RUNZSH=no --CHSH=yes
}

install_pipx() {
  pkg-install.sh ghbin pypa/pipx pipx.pyz pipx
}

install_rclone() {
  pkg-install.sh ghbin rclone/rclone "-linux-%arch:x86_64=amd64:aarch64=arm64%.zip$" "rclone-*/rclone"
}

install_restic() {
  install.sh ghbin restic/restic "_linux_%arch:x86_64=amd64:aarch64=arm64%.bz2$" restic
}

install_shfmt() {
  pkg-install.sh ghbin mvdan/sh "_linux_%arch:x86_64=amd64:aarch64=arm64%$" shfmt
}

install_uv() {
  pkg-install.sh ghbin astral-sh/uv "uv-x86_64-unknown-linux-gnu.tar.gz" uv
}

install_task() {
  sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin
}

install_yt_dlp() {
  pkg-install.sh ghbin yt-dlp/yt-dlp "_linux%arch:x86_64=:aarch64=_aarch64%$" yt-dlp
}

install_woodpecker_cli() {
  pkg-install.sh ghbin woodpecker-ci/woodpecker "woodpecker-cli_linux_%arch:x86_64=amd64:aarch64=arm64%.tar.gz$" woodpecker-cli
}

cd "${HOME}"
export -f $(compgen -A function)

if [ $# -eq 1 ]; then
  install_$1
else
  parallel --keep-order -vj0 install_{} ::: $@
fi
