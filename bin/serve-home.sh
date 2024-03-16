#!/bin/bash
screen -dmS serve_home bash -c "
  cd ~
  . ./.profile
  rclone serve webdav \
    --addr localhost:20711 \
    --dir-cache-time 0s \
    --user esperoj --pass "${MY_UUID}" \
    -L .
"
