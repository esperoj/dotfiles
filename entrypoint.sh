#!/bin/bash
. ${HOME}/.asdf/asdf.sh
chezmoi init --apply --force
bash -s <<-_EOL_
	. ~/.profile
	${1}
_EOL_
