[![status-badge](https://ci.codeberg.org/api/badges/12554/status.svg)](https://ci.codeberg.org/repos/12554)

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
