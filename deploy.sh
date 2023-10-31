#!/bin/bash

# master commit
git add .
git commit -m "$(date +%Y).$(date +%m).$(date +%d)"
# master push
git push --set-upstream origin master
# check out gh-pages
git checkout gh-pages
# merge master
git merge master
# push gh-pages
git push --set-upstream origin gh-pages

git checkout master
