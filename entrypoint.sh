#!/bin/bash
chezmoi update
source "${HOME}/.profile"
$@
