#!/bin/bash

OS_TYPE=$(uname)
if [ "$OS_TYPE" == "Linux" ]; then
  OS="linux"
elif [ "$OS_TYPE" == "FreeBSD" ]; then
  OS="freebsd"
else
  OS="unknown"
fi

if [ "$(id -u)" -eq 0 ]; then
  export SUDO_COMMAND=""
else
  export SUDO_COMMAND="sudo"
fi

install_7zip() {
  pkg-install.sh ghbin ip7z/7zip "${OS}-%arch:x86_64=x64:aarch64=arm64%.tar.xz$" "7zz"
}

install_asdf() {
  git clone --depth 1 https://github.com/asdf-vm/asdf.git ~/.asdf --branch master
  . "${HOME}/.asdf/asdf.sh"
}

install_bitwarden_cli() {
  pkg-install.sh bin "https://vault.bitwarden.com/download/?app=cli&platform=linux&name=bitwarden_cli.zip" bw
}

install_caddy() {
  pkg-install.sh ghbin caddyserver/caddy "${OS}_%arch:x86_64=amd64:aarch64=arm64%.tar.gz$" "caddy"
}

install_chezmoi() {
  sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ".local/bin"
}

install_dotfiles() {
  export MACHINE_TYPE=${MACHINE_TYPE-container}
  cd "${HOME}"
  chezmoi="${HOME}/.local/bin/chezmoi"
  if command -v chezmoi >/dev/null; then
    chezmoi="$(command -v chezmoi)"
  else
    sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${HOME}/.local/bin"
  fi
  chezmoi_path=".local/share/chezmoi"
  mkdir -p "${chezmoi_path}"
  (
    cd "${chezmoi_path}"
    git clone --depth=1 https://github.com/esperoj/dotfiles.git .
    git remote set-url origin git@github.com:esperoj/dotfiles.git
    git remote set-url origin --push --add git@github.com:esperoj/dotfiles.git
    git remote set-url origin --push --add git@codeberg.org:esperoj/dotfiles.git
  )
  ln -s "${chezmoi_path}"/{bin,data,scripts} .

  if [[ $APPLY == "true" ]]; then
    "${chezmoi}" init --apply --depth=1 --force
  fi
}

install_filen() {
  pkg-install.sh ghbin FilenCloudDienste/filen-cli "linux-%arch:x86_64=x64:aarch64=arm64%$" filen
}

install_fzf() {
  git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  ~/.fzf/install --key-bindings --completion --no-update-rc
}

install_esperoj() {
  pkg-install.sh ghbin esperoj/esperoj "^esperoj_linux_%arch:x86_64=x86_64:aarch64=aarch64%$" esperoj
}

install_gallery_dl() {
  pipx install gallery-dl
}

install_kopia() {
  pkg-install.sh ghbin kopia/kopia "-linux-%arch:x86_64=x64:aarch64=arm64%.tar.gz$" kopia
}

install_mdbook() {
  pkg-install.sh ghbin rust-lang/mdBook "%arch:x86_64=x86_64:aarch64=aarch64%.unknown-linux-musl.tar.gz$" mdbook
}

install_oh_my_zsh() {
  curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | bash -s -- --RUNZSH=no --CHSH=yes
}

install_pipx() {
  pkg-install.sh ghbin pypa/pipx pipx.pyz pipx
}

install_rclone() {
  pkg-install.sh ghbin rclone/rclone "-${OS}-%arch:x86_64=amd64:aarch64=arm64%.zip$" "rclone-*/rclone"
}

install_restic() {
  install.sh ghbin restic/restic "_linux_%arch:x86_64=amd64:aarch64=arm64%.bz2$" restic
}

install_shfmt() {
  pkg-install.sh ghbin mvdan/sh "_linux_%arch:x86_64=amd64:aarch64=arm64%$" shfmt
}

install_uv() {
  pkg-install.sh ghbin astral-sh/uv "uv-%arch:x86_64=x86_64:aarch64=aarch64%-unknown-linux-gnu.tar.gz" uv
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
parallelable_installs=("7zip" "asdf" "bitwarden_cli" "caddy" "chezmoi" "dotfiles" "filen" "fzf" "esperoj" "kopia" "mdbook" "oh_my_zsh" "pipx" "rclone" "restic" "shfmt" "uv" "task" "yt-dlp" "woodpecker-cli")
is_parallelable() {
  local name="$1"
  local package
  for package in "${parallelable_installs[@]}"; do
    if [[ "$package" == "$name" ]]; then
      return 0
    fi
  done
  return 1
}

main() {
  if [ $# -eq 1 ]; then
    if is_parallelable "${1}"; then
      "install_${1}"
    else
      sudo apt-get install -y --no-install-recommends "${1}"
    fi
  else
    export install_in_parallel_packages=""
    export install_using_apt_packages=""
    local package
    for package in "$@"; do
      if is_parallelable "${package}"; then
        install_in_parallel_packages+="${package} "
      else
        install_using_apt_packages+="${package} "
      fi
    done
    parallel --keep-order -vj0 {} <<EOL
    [[ -n "${install_using_apt_packages}" ]] && $SUDO_COMMAND apt-get install -q=2 --no-install-recommends $(echo "${install_using_apt_packages}")
    [[ -n "${install_in_parallel_packages}" ]] && parallel --keep-order -vj0 "$0" {} ::: $(echo "${install_in_parallel_packages}")
EOL
  fi
}

main "$@"
