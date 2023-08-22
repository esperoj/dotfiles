#!/bin/bash
chezmoi init --apply --force
bash -s <<-_EOL_
	. ~/.profile
	${1}
_EOL_
