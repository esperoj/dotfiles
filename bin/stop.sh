#!/bin/bash

stop() {
  tmux send-keys -t $1 C-c
}

for service in "$@"; do
  case "${service}" in
  home)
    stop home
    ;;
  esperoj)
    stop esperoj
    ;;
  esperoj_storage)
    stop esperoj_storage
    ;;
  caddy)
    caddy stop
    ;;
  ssh_server)
    ssh -O exit serveo-ssh-tunnel
    service ssh stop
    ;;
  wireproxy)
    stop wireproxy
    ;;
  esac
done
