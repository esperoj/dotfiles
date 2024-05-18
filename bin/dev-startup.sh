#!/bin/bash

# Setup enviroment
file_path="${HOME}/end"
archive="dev.tar.zst"
export RCLONE_VERBOSE=1
cd "${HOME}"

# Start ssh tunnel and other services in background
start-ssh-server.sh
serve-home.sh

# Restore cache and working workspace
rclone copy "b2:esperoj-cache/${archive}" .
time tar --zstd -xf "${archive}"
rm "${archive}"

# Check uptime until the end
while true; do
  sleep 60
  if [ -f "$file_path" ]; then
    echo "File found: $file_path"
    break
  fi
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -J serveo.net root@serveo.esperoj.eu.org uptime
done

ssh -O exit serveo-ssh-tunnel

# Upload cache and workspace
time tar -I "zstd -T$(nproc) -9" -cpf "${archive}" workspace .cache .zsh_history
rclone copy "${archive}" "b2:esperoj-cache"

exit
