#!/bin/sh

ssh-keyscan -f "${HOME}/.config/common/ssh-hosts.txt" >~/.ssh/known_hosts
