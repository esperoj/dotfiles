#!/bin/bash
set -Exeo pipefail
cd "${HOME}"

keep_pcloud_active() {
  echo "${RANDOM}" > ping.txt
  rclone -v copy ping.txt pcloud:
  rm ping.txt
}

export -f keep_pcloud_active fresh_feeds

parallel --keep-order -vj0 {} <<-EOL
  ssh ct8 "devil info account"
  ssh serv00 "devil info account"
  keep_pcloud_active
EOL
