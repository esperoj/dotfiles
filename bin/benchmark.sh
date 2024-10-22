#!/bin/bash

set -Eexo pipefail
curl -sL nws.sh | bash
curl -fLsS "https://yabs.sh" | bash -s -- -is "https://www.vpsbenchmarks.com/yabs/upload"
7z b
