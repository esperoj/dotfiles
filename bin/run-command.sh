#!/bin/bash
woodpecker-cli pipeline create --branch="main" --var "WORKFLOW=run-command" --var "COMMAND=${1}" esperoj/dotfiles
