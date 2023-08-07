# Install

```sh
export ENCRYPTION_PASSPHRASE=""
export MACHINE_NAME="segfault"
export PACKAGES="BASE NET DEV INTERACTIVE BIG"

apt-get update -qqy
apt-get upgrade -qqy
apt-get install -qqy curl gnupg openssh-client
cd ~
git clone --depth=1 https://codeberg.org/esperoj/dotfiles.git 
cd dotfiles
export PATH="$(pwd)/scripts:$PATH"
bash -c 'source setup.sh setup_ssh'
bash -c 'source setup.sh install'
. "$HOME/.asdf/asdf.sh"
chezmoi init --apply
```
