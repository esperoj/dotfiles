[![status-badge](https://ci.codeberg.org/api/badges/12554/status.svg)](https://ci.codeberg.org/repos/12554)

# Install

```bash
export ENCRYPTION_PASSPHRASE=""
export MACHINE_NAME=segfault
# Install dotfiles
curl -fsLS https://codeberg.org/esperoj/dotfiles/raw/branch/main/bin/install-dotfiles.sh | bash
~/bin/setup.sh
~/bin/entrypoint.sh "rclone copy -v koofr:working working"
```
