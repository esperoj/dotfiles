#!/bin/bash
set -Eeo pipefail
cd ~
rclone sync -v gdrive:working working
restic backup working -o s3.connections=32 -v -H "${MACHINE_NAME}"
restic forget -o s3.connections=32 --keep-daily 30 --verbose=3 --keep-weekly 5 --keep-monthly 12 --keep-yearly 75 --prune --group-by paths,tags
