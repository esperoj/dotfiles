#!/bin/bash

set -Eeo pipefail
export RCLONE_VERBOSE=1
export RCLONE_FILTER_FROM="$(mktemp)"
cat <<EOL >"${RCLONE_FILTER_FROM}"
- .thumbnails/
- tmp/
EOL

backup_linkwarden() {
  local TEMP_DIR="$(mktemp -d)"
  curl -s -H "Authorization: Bearer ${LINKWARDEN_ACCESS_TOKEN}" \
    "https://links.adminforge.de/api/v1/migration" >"${TEMP_DIR}/linkwarden-backup.json"
  rclone move "${TEMP_DIR}" "workspace:backup"
  rm -r "${TEMP_DIR}"
}

backup_seatable() {
  local TEMP_DIR="$(mktemp -d)"
  cd "${TEMP_DIR}"
  esperoj export_database "Primary"
  rclone copy . "workspace:backup/database"
  rm -r "${TEMP_DIR}"
}

export -f backup_linkwarden backup_seatable

backup_container() {
  cd ~
  pipx upgrade esperoj
  parallel --keep-order -vj0 {} <<EOL
  backup_linkwarden
  backup_seatable
EOL

  parallel --keep-order -vj0 {} <<EOL
  rclone sync workspace:backup ./backup
  rclone sync workspace: workspace-backup:
EOL

  7zz a "-p${ENCRYPTION_PASSPHRASE}" backup.7z ./backup
  rclone move -v backup.7z pcloud:public
  if [ "$(date +%A)" == "Monday" ]; then
    curl -sL -X POST https://builder.statichost.eu/esperoj-esperoj
  fi
}

backup_segfault() {
  echo backup
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
  curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/${PING_UUID}/daily-backup/start"
  backup_container
  curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/${PING_UUID}/daily-backup/${?}"
  ;;
segfault)
  curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/${PING_UUID}/daily-backup/start"
  backup_segfault
  curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/${PING_UUID}/daily-backup/${?}"
  ;;
esac

cleanup
