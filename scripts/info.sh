#!/bin/bash
set -Eeuxo pipefail
cd "${HOME}"
chezmoi status
lsb_release -a
uname -a
cat .tool-versions
rclone listremotes
restic check
python --version
node --version
7z i
ssh segfault "uname -a; lsb_release -a"
ssh envs "uname -a; lsb_release -a"
ssh serv00 "uname -a"
ssh ct8 "uname -a"
