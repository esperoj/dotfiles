#!/bin/bash

for service in "$@"; do
  case "${service}" in
  home)
    screen -S home -X stuff "^C"
    ;;
  esperoj_storage)
    screen -S esperoj_storage -X stuff "^C"
    ;;
  esperoj)
    screen -S esperoj -X stuff "^C"
    ;;
  caddy)
    caddy stop
    ;;
  ssh_server)
    ssh -O exit serveo-ssh-tunnel
    service ssh stop
    ;;
  esac
done
