#!/bin/bash

set -Eeo pipefail
export RCLONE_VERBOSE=1
export RCLONE_FLAGS="--exclude='{tmp/**,.thumbnails/**}'"

backup_linkwarden() {
  local TEMP_DIR="$(mktemp -d)"
  curl -s -H "Authorization: Bearer ${LINKWARDEN_ACCESS_TOKEN}" \
    "https://links.adminforge.de/api/v1/migration" >"${TEMP_DIR}/linkwarden-backup.json"
  rclone move "${TEMP_DIR}" "esperoj:backup-0"
  rm -r "${TEMP_DIR}"
}

backup_seatable() {
  local TEMP_DIR="$(mktemp -d)"
  cd "${TEMP_DIR}"
  esperoj export_database "primary"
  rclone sync . "esperoj:backup-0/database"
  rm -r "${TEMP_DIR}"
}

update_backup() {
  (
    rclone copy esperoj:public/backup.7z .
    7z x "-p${ENCRYPTION_PASSPHRASE}" backup.7z
    mkdir -p backup && cd ./backup
    rm -rf code
    rclone sync esperoj:backup-0 .
    mkdir -p code
    cd code
    parallel --keep-order -vj0 {} <<EOL
      git clone --depth=1 git@github.com:esperoj/dotfiles.git
      git clone --depth=1 git@github.com:esperoj/notebook.git
      git clone --depth=1 git@github.com:esperoj/archive.git
      git clone --depth=1 git@github.com:esperoj/esperoj.git
EOL
  )
  7z a -mx9 "-p${ENCRYPTION_PASSPHRASE}" backup.7z ./backup
  rm -rf backup/
  rclone move backup.7z esperoj:public
  if [[ $(date +%w) -eq 0 || $(date +%w) -eq 3 ]]; then
    echo esperoj save_page "https://public.esperoj.eu.org/backup.7z"
  fi
}

export -f backup_linkwarden backup_seatable update_backup

backup_container() {
  cd ~
  parallel --keep-order -vj0 {} <<EOL
  backup_linkwarden
  echo backup_seatable
EOL
  parallel --keep-order -vj0 {} <<EOL
  update_backup
  rclone sync esperoj:workspace-0 esperoj:workspace-1
EOL
}

backup_phone() {
  cd /sdcard
  rclone bisync "${RCLONE_FLAGS}" ./workspace esperoj:workspace-0
  rclone bisync "${RCLONE_FLAGS}" ./backup esperoj:backup-0
}

case "${MACHINE_TYPE}" in
phone)
  backup_phone
  ;;
container | pubnix)
  backup_container
  ;;
esac
