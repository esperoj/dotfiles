#!/bin/bash
. "${HOME}/.asdf/asdf.sh"
chezmoi update
source "${HOME}/.profile"
$@
