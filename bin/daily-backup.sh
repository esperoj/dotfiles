#!/bin/bash

set -Eeo pipefail
export RCLONE_VERBOSE=1
export RCLONE_FLAGS="--exclude='{tmp/**,.thumbnails/**}'"
TEMP_DIR="$(mktemp -d)"

cleanup() {
  echo "Running cleanup after backup"
  rm -rf "${TEMP_DIR}"
}

generate_linkwarden_backup() {
  curl -s -H "Authorization: Bearer ${LINKWARDEN_ACCESS_TOKEN}" \
    "https://links.adminforge.de/api/v1/migration" >"linkwarden-backup.json"
}

generate_seatable_backup() {
  mkdir -p database
  (
    cd database
    esperoj export_database "primary"
  )
}

generate_bitwarden_backup() {
  install.sh bitwarden_cli
  bw config server "${BW_SERVER}"
  bw login --apikey
  export BW_SESSION=$(bw unlock --passwordenv BW_PASSWORD --raw)
  bw export --output bitwarden.json --format json
  bw logout
  7z a -mx9 "-p${ENCRYPTION_PASSPHRASE}" bitwarden.json.7z bitwarden.json
}

generate_code() {
  mkdir -p code
  (
    cd code
    parallel --keep-order -vj0 {} <<EOL
      git clone --depth=1 git@github.com:esperoj/dotfiles.git
      git clone --depth=1 git@github.com:esperoj/notebook.git
      git clone --depth=1 git@github.com:esperoj/archive.git
      git clone --depth=1 git@github.com:esperoj/esperoj.git
EOL
  )
}

generate_current_backup() {
  rclone copy esperoj:public/backup.7z .
  7z x "-p${ENCRYPTION_PASSPHRASE}" backup.7z
  rm backup.7z
  (
    cd backup
    rm -rf code
    rclone sync esperoj:backup-0 .
    # rm -rf database
  )
}

update_backup() {
  (
    cd "${TEMP_DIR}"
    parallel --keep-order -vj0 {} <<EOL
      generate_bitwarden_backup
      generate_code
      generate_linkwarden_backup
      generate_current_backup
      echo disable # generate_seatable_backup
EOL
    # TODO: Add database when esperoj working again
    mv bitwarden.json.7z code linkwarden-backup.json backup
    7z a -mx9 "-p${ENCRYPTION_PASSPHRASE}" backup.7z ./backup
    rm -rf backup/code
    parallel --keep-order -vj0 {} <<EOL
      rclone move backup.7z esperoj:public
      rclone sync ./backup esperoj:backup-0
      rclone sync ./backup esperoj:backup-0
EOL
  )
  if [[ $(date +%w) -eq 0 || $(date +%w) -eq 3 ]]; then
    echo esperoj save_page "https://public.esperoj.eu.org/backup.7z"
  fi
}

export -f generate_bitwarden_backup generate_code generate_linkwarden_backup generate_current_backup generate_seatable_backup update_backup

backup_container() {
  cd ~
  parallel --keep-order -vj0 {} <<EOL
    rclone sync esperoj:workspace-0 esperoj:workspace-1
    rclone sync esperoj:archive-0 esperoj:archive-1
    update_backup
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
  trap cleanup EXIT
  backup_container
  ;;
esac
