#!/bin/bash
cd ~
serve_home_command='
  export RCLONE_PASS="${MY_UUID}"
  rclone serve webdav \
  --addr "unix://${HOME}/.sockets/home.sock" \
  --dir-cache-time 0s \
  --poll-interval 0 \
  --user esperoj \
  -L .'
serve_esperoj_storage_command='
  export RCLONE_AUTH_KEY="esperoj,${MY_UUID}"
  rclone serve s3 \
  --addr "unix://${HOME}/.sockets/pcloud.sock" \
  --dir-cache-time 0s \
  --poll-interval 0 \
  --vfs-cache-mode writes \
  esperoj:'
start_esperoj_command='
  esperoj start
'

for service in "$@"; do
  case "${service}" in
  home)
    screen -dmS home sh -lc "${serve_home_command}"
    ;;
  caddy)
    caddy start
    ;;
  esperoj)
    screen -dmS esperoj sh -lc "${start_esperoj_command}"
    ;;
  esperoj_storage)
    screen -dmS esperoj_storage sh -lc "${serve_esperoj_storage_command}"
    ;;
  ssh_server)
    service ssh start
    echo "Connecting to Serveo for forwarding..."
    ssh -f -N serveo-ssh-tunnel
    ;;
  esac
done
