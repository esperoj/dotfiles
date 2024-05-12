#!/bin/bash

cd ~
file_path="${HOME}/end"

start-ssh-server.sh
serve-home.sh

rclone copy -v pcloud:public/.zsh_history .
rclone copy -v pcloud:public/workspace.tar.zst .
tar --zstd -xf workspace.tar.zst
rm workspace.tar.zst

while true; do
  sleep 60
  if [ -f "$file_path" ]; then
    echo "File found: $file_path"
    break
  fi
  ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -J serveo.net root@serveo.esperoj.eu.org uptime
done

command time -v tar -I 'zstd -T$(nproc) -9' -cpf workspace.tar.zst workspace
rclone copy -v .zsh_history pcloud:public
rclone copy -v workspace.tar.zst pcloud:public

ssh -O exit serveo-ssh-tunnel
sleep 1
echo "Exiting script"
exit
