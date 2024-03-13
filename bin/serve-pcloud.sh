#!/bin/bash
. ~/.profile
rclone serve http \
  --addr "[::]:${PORT}" \
  --dir-cache-time 0s \
  pcloud:public
