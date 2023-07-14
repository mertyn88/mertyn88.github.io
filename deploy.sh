#!/bin/bash

git checkout -b origin/gh-pages
git merge master
git add .
git commit -m "$(date +%Y).$(date +%m).$(date +%d)"
git push --set-upstream origin gh-pages
