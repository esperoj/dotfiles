#!/bin/bash

service ssh start

echo "Connecting to Serveo for forwarding..."
ssh -f -N serveo-ssh-tunnel
