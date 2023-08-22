#!/bin/sh
git checkout --orphan latest_branch
git add -A
git commit -am "First commit"
git branch -D main
git branch -m main
git push -f origin main
