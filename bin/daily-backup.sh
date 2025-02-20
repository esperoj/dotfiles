#!/bin/bash

set -Eeuo pipefail
export RCLONE_VERBOSE=1
export RCLONE_FLAGS=--exclude="{tmp/**,.*,.*/**}"
export TEMP_DIR="$(mktemp -d)"
cd "$TEMP_DIR"

cleanup() {
  echo "Running cleanup after backup"
  rm -rf "${TEMP_DIR}"
}

run() {
  command time --format "Command: %C\nReal Time: %E\nUser Time: %U\nSystem Time: %S\nCPU Percentage: %P" bash -c "$1"
}

generate_linkwarden_backup() {
  curl -fsSm 10 --retry 5 -H "Authorization: Bearer ${LINKWARDEN_ACCESS_TOKEN}" \
    "https://links.adminforge.de/api/v1/migration" >"linkwarden-backup.json"
}

generate_seatable_backup() {
  mkdir database
  (
    cd database
    esperoj export_database primary
  )
}

generate_bitwarden_backup() {
  install.sh bitwarden_cli
  bw config server "${BW_SERVER}"
  bw login --apikey
  export BW_SESSION="$(bw unlock --passwordenv BW_PASSWORD --raw)"
  bw export --output bitwarden.json --format json
  bw logout
  7z a -mx9 "-p${ENCRYPTION_PASSPHRASE}" bitwarden.json.7z bitwarden.json
}

generate_code() {
  mkdir -p code
  (
    cd code
    parallel --keep-order -vj0 wget -qO {}.zip https://github.com/esperoj/{}/archive/refs/heads/main.zip ::: archive dotfiles esperoj notebook
  )
}

generate_current_backup() {
  rclone copy public:backup.7z .
  7z x "-p${ENCRYPTION_PASSPHRASE}" backup.7z
  rm backup.7z
  (
    cd backup
    rclone sync backup-0: .
    rm -rf code database
  )
}

update_backup() {
  export JOURNAL_FILE="./backup/database/journal.json"
  parallel --keep-order -vj0 run '{}' ::: \
    'generate_code' \
    'generate_linkwarden_backup' \
    'generate_current_backup' \
    'generate_seatable_backup' \
    'generate_bitwarden_backup'
  mv database/ code/ bitwarden.json.7z linkwarden-backup.json ./backup/
  7z a -mx9 "-p${ENCRYPTION_PASSPHRASE}" backup.7z ./backup/
  parallel --keep-order -vj0 run '{}' ::: \
    'parallel --keep-order -vj0 rclone sync ./backup "{}" ::: "backup-0:" "backup-1:"' \
    'rclone move backup.7z public: && esperoj save_page "https://public.esperoj.eu.org/backup.7z"' \
    '[[ -f $JOURNAL_FILE && $(stat -c%s $JOURNAL_FILE) -gt 100000 ]] && rclone copy -v "$JOURNAL_FILE" ia:xiaoqishi_riji --header-upload x-archive-keep-old-version:32'
}

export -f generate_bitwarden_backup generate_code generate_linkwarden_backup generate_current_backup generate_seatable_backup run update_backup

backup_container() {
  parallel --keep-order -vj0 run '{}' ::: \
    'update_backup' \
    'parallel --keep-order -vj0 rclone sync {}-0: {}-1: ::: workspace archive mimi'
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null envs <<EOL
    source ~/.profile ;
    echo $(date) > date.txt ;
    parallel --keep-order -vj2 rclone sync -v ./date.txt {} ::: "cloudinary:" "dropbox:" "imagekit:" "mega:" "onedrive:" "pcloud-0:" "pcloud-1:" "uloz:"
EOL
}

backup_phone() {
  cd /sdcard
  rclone bisync --no-check-certificate --password-command "echo $RCLONE_CONFIG_PASS" "${RCLONE_FLAGS}" ./workspace workspace-0:
  rclone bisync --no-check-certificate --password-command "echo $RCLONE_CONFIG_PASS" "${RCLONE_FLAGS}" ./backup backup-0:
}

case "${MACHINE_TYPE}" in
phone)
  time backup_phone
  ;;
container | pubnix)
  trap cleanup EXIT
  backup_container
  ;;
esac
