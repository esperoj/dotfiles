#!/bin/bash
rclone serve s3 \
  --addr localhost:20711 \
  --vfs-cache-mode writes \
  --auth-key "esperoj,${MY_UUID}" \
  pcloud:
