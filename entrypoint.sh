#!/bin/bash
. ${HOME}/.asdf/asdf.sh
chezmoi init --apply --force
bash -s <<<'source ${HOME}/.profile || exit 1 ; '${1@Q}
