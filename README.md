[![status-badge](https://ci.codeberg.org/api/badges/12554/status.svg)](https://ci.codeberg.org/repos/12554)

# Install Example

```bash
cd ~
export MACHINE_TYPE=phone
export ENCRYPTION_PASSPHRASE=""

# Install dotfiles
apt-get update -y
apt-get upgrade -y
apt-get install --no-install-recommends -y git chezmoi gnupg
curl -fsLS https://codeberg.org/esperoj/dotfiles/raw/branch/main/bin/install.sh | APPLY=true bash -s -- dotfiles
. ./.profile
setup.sh termux
```

## Remove old history

```bash
git checkout --orphan latest_branch 
git add -A
git commit -am "init [skip ci]"
git branch -D main
git branch -m main
git push -f origin main
```