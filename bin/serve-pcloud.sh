#!/bin/bash
. ~/.profile
rclone serve s3 \
  --addr "[::]:${PORT}" \
  --dir-cache-time 0s \
  --vfs-cache-mode writes \
  --auth-key "esperoj,${MY_UUID}" \
  pcloud:
