#!/bin/bash
set -Exeo pipefail
cd "/storage/emulated/0/"
rclone sync -v ./working koofr:working --exclude ".thumbnails/"
rclone sync -v ./ePSXe koofr:ePSXe
rclone sync -v ./music koofr:music --exclude ".thumbnails/"
