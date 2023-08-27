# Install
```bash
cd ~
export ENCRYPTION_PASSPHRASE=""
export MACHINE_NAME=segfault
curl -fsLS https://codeberg.org/esperoj/dotfiles/raw/branch/main/bin/setup.sh | bash
"${HOME}/.local/bin/chezmoi" init --apply --force
. ~/.profile
rclone copy -v koofr:working working
```
