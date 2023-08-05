#!/bin/bash
. "${HOME}/.asdf/asdf.sh"
chezmoi init --apply --force
chezmoi update
source "${HOME}/.profile"
$@
