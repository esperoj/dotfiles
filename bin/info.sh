#!/bin/bash

set -Eexo pipefail
cd "${HOME}"

parallel --keep-order -vj0 {} <<-EOL
  chezmoi status
  curl -fLsS "https://ipwho.de"
  df -hT
  esperoj --help
  free -h
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
