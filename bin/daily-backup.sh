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
  mkdir -p database
  (
    cd database
    esperoj export_database "primary"
  )
}

bitwarden_backup() {
  install.sh bitwarden_cli
  bw config server "${BW_SERVER}"
  bw login --apikey
  export BW_SESSION="$(bw unlock --passwordenv BW_PASSWORD --raw)"
  bw export --output bitwarden.json --format json
  bw logout
  7z a -mx9 "-p${ENCRYPTION_PASSPHRASE}" bitwarden.json.7z bitwarden.json
  parallel --keep-order -vj0 {} <<EOL
    rclone copy bitwarden.json.7z backup-0:
    rclone copy bitwarden.json.7z backup-1:
EOL
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
    rm -rf code
  )
}

update_backup() {
  (
    parallel --keep-order -vj0 {} <<EOL
      run generate_code
      run generate_linkwarden_backup
      run generate_current_backup
      echo generate_seatable_backup
EOL
    # TODO: Add database when esperoj working again
    mv code linkwarden-backup.json backup
    7z a -mx9 "-p${ENCRYPTION_PASSPHRASE}" backup.7z ./backup
    rclone move backup.7z public:
    parallel --keep-order -vj0 rclone sync --exclude='bitwarden.json.7z' ./backup "{}" ::: "backup-0:" "backup-1:" "mega:esperoj/backup"
  )
  if [[ $(date +%w) -eq 0 || $(date +%w) -eq 3 ]]; then
    esperoj save_page "https://public.esperoj.eu.org/backup.7z"
  fi
}

export -f bitwarden_backup generate_code generate_linkwarden_backup generate_current_backup generate_seatable_backup run update_backup

backup_container() {
  parallel --keep-order -vj0 {} <<EOL
    run 'rclone sync workspace-0: workspace-1:'
    run 'rclone sync archive-0: archive-1:'
    run update_backup
    run bitwarden_backup
EOL
  parallel --keep-order -vj1 ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null {} '
  chezmoi update;
  . ~/.profile ;
  parallel --keep-order -vj0 "
    rclone sync -v megadisk:esperoj jottacloud:esperoj
    rclone sync -v megadisk:esperoj nch:esperoj"' ::: serv00 envs hashbang
}

backup_phone() {
  cd /sdcard
  rclone bisync "${RCLONE_FLAGS}" ./workspace workspace-0:
  rclone bisync "${RCLONE_FLAGS}" ./backup backup-0:
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
