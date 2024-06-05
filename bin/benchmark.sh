#!/bin/bash
set -Eexo pipefail
curl -fLsS "https://raw.githubusercontent.com/su-haris/simple-network-speedtest/master/speed.sh" | bash
curl -fLsS "https://yabs.sh" | bash -s -- -is "https://www.vpsbenchmarks.com/yabs/upload"
rclone copy -v --transfers 32 koofr:audio ./audio
rm -r ./audio
7z b
