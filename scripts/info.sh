#!/bin/bash
set -Eeuxo pipefail
chezmoi update
lsb_release -a
uname -a
rclone listremotes
restic stats
python --version
node --version
ssh segfault "uname -a; lsb_release -a"
ssh envs "uname -a; lsb_release -a"
ssh serv00 "uname -a"
ssh ct8 "uname -a"
ssh git@codeberg.org
ssh git@github.com
