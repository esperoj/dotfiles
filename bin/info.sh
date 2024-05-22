#!/bin/bash

set -Eeuxo pipefail
cd "${HOME}"

parallel --keep-order -vj0 {} <<-EOL
  7z
  chezmoi status
  curl -fLsS "https://ipwho.de"
  df -hT
  esperoj --help
  free -h
  inxi -ABCDEGIJLMNPRSWdfijlmnoprstuw
  # kopia --version
  node --version
  pwd
  python --version
  rclone listremotes
  ssh ct8 "uname -a"
  ssh envs "uname -a; lsb_release -a"
  ssh hashbang "uname -a; lsb_release -a"
  [[ ${MACHINE_NAME@Q} == "segfault" ]] || ssh segfault "uname -a; lsb_release -a"
  ssh serv00 "uname -a"
  uptime
EOL
