#!/bin/bash
. "${HOME}/.asdf/asdf.sh"
chezmoi init --apply --force
source "${HOME}/.profile"
$@
