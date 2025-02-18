[![status-badge](https://ci.codeberg.org/api/badges/12554/status.svg)](https://ci.codeberg.org/repos/12554)

# Install Example

```bash
cd ~
read MACHINE_TYPE
export MACHINE_TYPE="${MACHINE_TYPE:-phone}"
read ENCRYPTION_PASSPHRASE
export ENCRYPTION_PASSPHRASE="$ENCRYPTION_PASSPHRASE"

# Install dotfiles
apt-get update -y
apt-get upgrade -y
apt-get install --no-install-recommends -y git chezmoi gnupg
curl -fsLS https://raw.githubusercontent.com/esperoj/dotfiles/refs/heads/main/bin/install.sh | APPLY=true bash -s -- dotfiles
. ./.profile
setup.sh termux
```