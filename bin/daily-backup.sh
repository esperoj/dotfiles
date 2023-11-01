#!/bin/bash
set -Exeo pipefail
export RCLONE_VERBOSE=1
export RCLONE_FILTER_FROM="$(mktemp)"
cat <<-EOL >"${RCLONE_FILTER_FROM}"
- .thumbnails/
- tmp/
EOL

backup_phone() {
  cd "/storage/emulated/0/"
  echo "- joplin/" >> "${RCLONE_FILTER_FROM}"
  rclone sync ./workspace workspace:
  rclone sync ./music koofr:music
}

backup_segfault() {
  cd ~
  rclone sync workspace: ./workspace
  restic backup --no-scan --host "${MACHINE_NAME}" workspace
  restic forget --keep-daily 30 --keep-weekly 5 --keep-monthly 12 --keep-yearly 75 --prune
  restic check
}

cleanup() {
  rm "${RCLONE_FILTER_FROM}"
}

case "${MACHINE_NAME}" in
phone)
  backup_phone
  ;;
segfault)
  curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/${PING_UUID}/daily-backup/start"
  backup_segfault
  curl -fsS -m 10 --retry 5 -o /dev/null "https://hc-ping.com/${PING_UUID}/daily-backup/${?}"
  ;;
esac

cleanup
