#!/bin/bash

set -Exeo pipefail
export RCLONE_VERBOSE=1
export RCLONE_FILTER_FROM="$(mktemp)"
cat <<-EOL >"${RCLONE_FILTER_FROM}"
	- .thumbnails/
	- tmp/
EOL

backup_linkwarden() {
  local TEMP_DIR="$(mktemp -d)"
  curl -s -H "Authorization: Bearer ${LINKWARDEN_ACCESS_TOKEN}" \
    "https://links.adminforge.de/api/v1/migration" >"${TEMP_DIR}/linkwarden-backup.json"
  rclone move "${TEMP_DIR}" "workspace:backup/"
}

backup_seatable() {
  local TEMP_DIR="$(mktemp -d)"
  cd "${TEMP_DIR}"
  esperoj export_database "Primary"
  rclone copy . "workspace:database"
  rm -r "${TEMP_DIR}"
}

export -f backup_linkwarden backup_seatable

backup_container() {
  parallel --keep-order -vj0 {} <<-EOL
  ssh envs bash -s <<<'${HOME}/bin/daily-backup.sh'
  rclone sync --transfers 8 pcloud: nch:
EOL
}

backup_segfault() {
  cd ~
  source ./.profile
  chezmoi update --force --no-tty
  source ./.profile
  parallel --keep-order -vj0 {} <<-EOL
  backup_linkwarden
  backup_seatable
EOL

  parallel --keep-order -vj0 {} <<-EOL
  rclone sync workspace: ./workspace
  rclone sync joplin: ./joplin
  kopia snapshot create "./.local/share/chezmoi"
EOL

  kopia snapshot create "./workspace"
  kopia snapshot create "./joplin"
  kopia maintenance run --full
}

cleanup() {
  rm "${RCLONE_FILTER_FROM}"
}

uptime
date --utc

case "${MACHINE_NAME}" in
phone)
  backup_phone
  ;;
container)
  backup_container
  ;;
segfault)
  curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/${PING_UUID}/daily-backup/start"
  backup_segfault
  curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/${PING_UUID}/daily-backup/${?}"
  ;;
esac

cleanup
