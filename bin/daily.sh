#!/bin/bash
set -Exeo pipefail
cd "${HOME}"

keep_pcloud_active() {
  echo "${RANDOM}" > ping.txt
  rclone -v copy ping.txt pcloud:
  rm ping.txt
}

fresh_feeds() {
  curl -fsS -m 300 --retry 5 "https://frss.adminforge.de/i/?c=feed&a=actualize&force=1&user=esperoj&token=${MY_UUID}&ajax=1"
}

export -f keep_pcloud_active fresh_feeds

parallel --keep-order -vj0 {} <<-EOL
  ssh ct8 "devil info account"
  ssh serv00 "devil info account"
  keep_pcloud_active
  fresh_feeds
EOL
