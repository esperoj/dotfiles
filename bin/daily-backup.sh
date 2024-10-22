#!/bin/bash

set -Eeo pipefail
export RCLONE_VERBOSE=1
export RCLONE_FLAGS="--exclude='{tmp/**,.thumbnails/**}'"

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
  esperoj export_database "primary"
  rclone sync . "workspace:backup/database"
  rm -r "${TEMP_DIR}"
}

update_backup() {
  rclone copy workspace:backup ./backup
  7z a "-p${ENCRYPTION_PASSPHRASE}" backup.7z ./backup
  rm -rf backup/
  rclone move backup.7z public:
  esperoj save_page "https://esperoj.vercel.app/backup.7z"
  esperoj save_page "https://esperoj.vercel.app/print.html"
}

export -f backup_linkwarden backup_seatable update_backup

backup_container() {
  cd ~
  parallel --keep-order -vj0 {} <<EOL
  backup_linkwarden
  backup_seatable
EOL
  parallel --keep-order -vj0 {} <<EOL
  esperoj save_page "https://esperoj.vercel.app"
  update_backup
  rclone sync workspace: workspace-backup:
EOL
}

backup_phone() {
  cd /sdcard
  rclone bisync "${RCLONE_FLAGS}" workspace: ./workspace
  rclone bisync "${RCLONE_FLAGS}" koofr:picture ./picture
  rclone bisync "${RCLONE_FLAGS}" koofr:audio ./audio
  rclone bisync "${RCLONE_FLAGS}" koofr:archive/book ./book
}

case "${MACHINE_TYPE}" in
phone)
  backup_phone
  ;;
container)
  backup_container
  ;;
esac
