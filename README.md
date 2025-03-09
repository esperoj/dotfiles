[![status-badge](https://ci.codeberg.org/api/badges/12554/status.svg)](https://ci.codeberg.org/repos/12554)

# Install Example

```bash
cd ~
echo "MACHINE_TYPE:"
read MACHINE_TYPE
export MACHINE_TYPE="${MACHINE_TYPE:-phone}"
echo "ENCRYPTION_PASSPHRASE:"
read ENCRYPTION_PASSPHRASE
export ENCRYPTION_PASSPHRASE="$ENCRYPTION_PASSPHRASE"

# Install dotfiles
apt-get -o "Acquire::https::Verify-Peer=false" --allow-unauthenticated update -y
apt-get -o "Acquire::https::Verify-Peer=false" --allow-unauthenticated upgrade -y
apt-get install -o "Acquire::https::Verify-Peer=false" --allow-unauthenticated --no-install-recommends -y git chezmoi gnupg
curl -fsLS https://raw.githubusercontent.com/esperoj/dotfiles/refs/heads/main/bin/install.sh | APPLY=true bash -s -- dotfiles
. ./.profile
setup.sh termux
```
