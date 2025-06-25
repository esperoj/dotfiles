#!/bin/bash

  cd "$HOME/.local/bin"
  rm -rf "$HOME/.local/opt/$1"
  find -L . -name . -o -type d -prune -o -type l -exec rm {} +
