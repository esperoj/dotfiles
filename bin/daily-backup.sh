#!/bin/bash
set -Exeo pipefail
export RCLONE_VERBOSE=1
export RCLONE_FILTER_FROM="$(mktemp)"
cat <<-EOL >"${RCLONE_FILTER_FROM}"
	- .thumbnails/
	- tmp/
EOL

backup_container() {
  ssh envs bash -s <<<'
    . ~/.profile
    chezmoi update
    . ~/.profile
    daily-backup.sh'
}

backup_phone() {
  cd "/storage/emulated/0/"
  echo "- joplin/" >>"${RCLONE_FILTER_FROM}"
  rclone sync ./workspace workspace:
  rclone sync ./music pcloud:Music
}

backup_segfault() {
  (
      TEMP_DIR="$(mktemp -d)"
      cd "${TEMP_DIR}"
      esperoj export_database "Primary"
      rclone copy . workspace:database
      rm -r "${TEMP_DIR}"
  )
  cd ~
  parallel --keep-order -vj0 {} <<-EOL
  rclone sync --transfers 8 pcloud: nch:
  rclone sync workspace: ./workspace
  rclone sync joplin: ./joplin
EOL
  kopia snapshot create "./workspace"
  kopia snapshot create "./.local/share/chezmoi"
  kopia snapshot create "./joplin"
  kopia maintenance run --full
}

cleanup() {
  rm "${RCLONE_FILTER_FROM}"
}

uptime

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
