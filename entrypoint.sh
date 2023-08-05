#!/bin/bash
chezmoi init --apply
source "${HOME}/.profile"
$@
