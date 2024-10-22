#!/bin/bash

scan() {
  local fn
  local port
  fn="$1"
  for port in $(grep -Eo ':[0-9]+' $fn | sed s/:// | sort | uniq); do
    sed -ne "s/:${port}//p" $fn | ssh-keyscan -f - -p "${port}"
  done
}

scan "${HOME}/.config/common/ssh-hosts.txt" >"${HOME}/.ssh/known_hosts"
