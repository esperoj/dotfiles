#!/bin/bash
set -Euxeo pipefail
export DEBIAN_FRONTEND=noninteractive
cd "${HOME}"
mkdir -p ".local/bin/"

packages="7zip
aria2
ffmpeg
jq
lsb-release
nodejs
parallel
rclone
restic
shfmt
sqlite3
sudo
time
yt-dlp"

apt-get update -y
xargs apt-get install -y --no-install-recommends <<<"${packages}"

# Post setup
ln -s ".local/share/chezmoi/bin" .
ln -s $(command -v 7zz) ".local/bin/7z"
ln -s $(command -v python3) ".local/bin/python"
mkdir -p ".ssh/sockets"
