#!/bin/bash
set -Euxeo pipefail
export DEBIAN_FRONTEND=noninteractive
cd "${HOME}"
mkdir ".local/bin/"

apt-get update -y
apt-get install -y --no-install-recommends <<-_EOL_
7zip
aria2
ffmpeg
jq
lsb-release
parallel
rclone
restic
shfmt
sqlite3
sudo
time
yt-dlp
_EOL_

# Post setup
ln -s ".local/share/chezmoi/bin" .
ln -s $(command -v 7zz) ".local/bin/7z"
ln -s $(command -v python3) ".local/bin/python"
mkdir -p ".ssh/sockets"
