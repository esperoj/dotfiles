#!/bin/bash
. ~/.profile
rclone serve s3 \
  --addr "[::]:${PORT}" \
  --dir-cache-time 0s \
  --poll-interval 0 \
  --vfs-cache-mode writes \
  --auth-key "esperoj,${MY_UUID}" \
  pcloud:
