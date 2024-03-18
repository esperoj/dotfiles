#!/bin/bash
screen -dmS serve_home bash -c "
  cd ~
  . ./.profile
  rclone serve webdav \
    --addr localhost:20711 \
    --dir-cache-time 0s \
    --poll-interval 0 \
    --user esperoj --pass "${MY_UUID}" \
    -L .
"
