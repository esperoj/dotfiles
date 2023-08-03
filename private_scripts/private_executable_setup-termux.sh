#!/bin/bash

echo "Do you want to setup Termux? (y/n)"
read -r input
if [ "$input" = "n" ]; then
	exit
elif [ "$input" = "y" ]; then
	cd ~ || exit
	pkg install -qy jq tmux wget aria2 restic rclone openssh git sshpass tree zsh p7zip rsync
	curl -s "https://api.doppler.com/v3/configs/config/secrets/download?format=env" --user "$DOPPLER_TOKEN:" >.env
	set -a
	source .env
	set +a
	mkdir -p "$(dirname "${RCLONE_CONFIG}")"
	wget -O "$RCLONE_CONFIG" "$RCLONE_CONFIG_URL"
	restic restore latest --tag Termux --path "$HOME" --target "$HOME/tmp"
	# sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
	chsh -s zsh
	termux-setup-storage
	termux-change-repo
	# autoload -Uz compinit && compinit
else
	exit
fi
