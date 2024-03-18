#!/bin/bash
. ~/.profile
rclone serve http \
  --addr "[::]:${PORT}" \
  --poll-interval 0 \
  --dir-cache-time 0s \
  pcloud:public
