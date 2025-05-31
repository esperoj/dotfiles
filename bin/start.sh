#!/bin/bash
cd ~

start() {
  name="$1"
  command_name="start_${name}_command"
  tmux new-session -d -s "${name}" "${!command_name}"
}

start_home_command='
  export RCLONE_PASS="${MY_UUID}"
  rclone serve webdav \
  --addr "unix://${HOME}/.sockets/home.sock" \
  --dir-cache-time 0s \
  --poll-interval 0 \
  --user esperoj \
  -L .'

start_esperoj_storage_command='
  export RCLONE_AUTH_KEY="esperoj,${MY_UUID}"
  rclone serve s3 \
  --addr "unix://${HOME}/.sockets/esperoj-storage.sock" \
  --dir-cache-time 0s \
  --poll-interval 0 \
  --vfs-cache-mode writes \
  esperoj:'

start_esperoj_command='
  esperoj start
'

start_wireproxy_command='
  cd ~/data && wireproxy -c wireproxy.conf
'

for service in "$@"; do
  case "${service}" in
  home)
    start home
    ;;
  caddy)
    caddy start
    ;;
  esperoj)
    start esperoj
    ;;
  esperoj_storage)
    start esperoj_storage
    ;;
  ssh_server)
    service ssh start
    echo "Connecting to Serveo for forwarding..."
    ssh -f -N serveo-ssh-tunnel
    ;;
  wireproxy)
    start wireproxy
    ;;
  esac
done
