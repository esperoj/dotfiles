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
serve_pcloud_command='
  export RCLONE_AUTH_KEY="esperoj,${MY_UUID}"
  rclone serve s3 \
  --addr "unix://${HOME}/.sockets/pcloud.sock" \
  --dir-cache-time 0s \
  --poll-interval 0 \
  --vfs-cache-mode writes \
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
