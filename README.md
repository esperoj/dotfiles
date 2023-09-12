[![status-badge](https://ci.codeberg.org/api/badges/12554/status.svg)](https://ci.codeberg.org/repos/12554)

# Install

```bash
cd ~
export ENCRYPTION_PASSPHRASE=""
export MACHINE_NAME=segfault
export RCLONE_FILTER_FROM="$(mktemp)"
cat <<-EOL >"${RCLONE_FILTER_FROM}"
- .thumbnails/
- tmp/
EOL
# Install dotfiles
curl -fsLS https://codeberg.org/esperoj/dotfiles/raw/branch/main/bin/install-dotfiles.sh | bash
export PATH="${HOME}/bin:${PATH}"
setup.sh
entrypoint.sh "rclone copy -v workspace: ./workspace"
info.sh
rm "${RCLONE_FILTER_FROM}"
```
