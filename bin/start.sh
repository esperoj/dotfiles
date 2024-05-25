#!/bin/bash
cd ~
serve_home_command='rclone serve webdav \
  --addr "unix://${HOME}/.sockets/home.sock" \
  --dir-cache-time 0s \
  --poll-interval 0 \
  --user esperoj --pass "${MY_UUID}" \
  -L .'
serve_pcloud_command='rclone serve s3 \
  --addr "unix://${HOME}/.sockets/pcloud.sock" \
  --dir-cache-time 0s \
  --poll-interval 0 \
  --vfs-cache-mode writes \
  --auth-key "esperoj,${MY_UUID}" \
  pcloud:'

for service in "$@"; do
  case "${service}" in
  home)
    screen -dmS home bash -lc "${serve_home_command}"
    ;;
  pcloud)
    screen -dmS pcloud bash -lc "${serve_pcloud_command}"
    ;;
  caddy)
    caddy start
    ;;
  ssh_server)
    service ssh start
    echo "Connecting to Serveo for forwarding..."
    ssh -f -N serveo-ssh-tunnel
    ;;
  esac
done
