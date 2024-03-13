#!/bin/bash
screen -dmS pcloud-public sh -c "
  rclone serve http \
    --addr localhost:20711 \
    pcloud:public
"
