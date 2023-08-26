#!/bin/bash
set -Eeuxo pipefail
pwd
curl -fLsS "https://ipwho.de"
df -h
free -h
# Test network speed
curl -fLsS "https://raw.githubusercontent.com/su-haris/simple-network-speedtest/master/speed.sh" | bash
curl -fLsS "https://yabs.sh" | bash -s -- -is "https://www.vpsbenchmarks.com/yabs/upload"
