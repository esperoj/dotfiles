#!/bin/bash

service ssh start

echo "Generating SSH host keys..."
ssh-keygen -A

# Start sshd
echo "Starting SSH server..."
#/usr/sbin/sshd -De "$@" &

echo "Connecting to Serveo for forwarding..."
ssh -f -N serveo-ssh-tunnel
