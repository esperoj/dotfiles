#!/bin/bash

echo "Do you want to perform the backup now? (y/n)"
read -r input
if [ "$input" = "n" ]; then
	exit
elif [ "$input" = "y" ]; then
	cd "$HOME" || exit
	#restic backup "$HOME" -o s3.connections=8 -v -H xiaomi-glt --tag termux --exclude-file="$HOME/excludes.txt"
	# restic forget -o s3.connections=8 --keep-daily 7 --verbose=3 --keep-weekly 5 --keep-monthly 12 --keep-yearly 75 --prune --group-by paths,tags
	rclone sync -v /sdcard/working nch.pl:working --exclude ".thumbnails/"
else
	exit
fi
