# Install

```sh
export ENCRYPTION_PASSPHRASE=""
export MACHINE_NAME="ci"
export PACKAGES="BASE NET"

apt-get update -qqy
apt-get install -qqy curl gnupg openssh-client
setup_ssh() {
        mkdir -p ~/.ssh
        curl -sSfl "https://codeberg.org/esperoj/dotfiles/raw/branch/main/private_dot_ssh/encrypted_private_id_ed25519.asc" | gpg --passphrase "${ENCRYPTION_PASSPHRASE}" --batch -d >~/.ssh/id_ed25519
        chmod 600 ~/.ssh/id_ed25519
        curl -sSfl "https://codeberg.org/esperoj/dotfiles/raw/branch/main/private_dot_ssh/private_known_hosts" >~/.ssh/known_hosts
}
setup_ssh
git clone --depth=1 --quiet git@codeberg.org:esperoj/dotfiles.git .local/share/chezmoi
```
