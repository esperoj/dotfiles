#!/bin/bash
. ${HOME}/.asdf/asdf.sh
chezmoi init --apply --force
bash -c "source ${HOME}/.profile
$@"
