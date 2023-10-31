#!/bin/bash

branch_name="feature/$(date +%Y).$(date +%m).$(date +%d)"

# check branch
if git rev-parse --quiet --verify "refs/heads/$branch_name" > /dev/null; then
  echo "exist $branch_name"
  git checkout $branch_name
else
  # create branch
  git checkout -b "$branch_name"
fi

# commit
git add .
git commit -m "$(date +%Y).$(date +%m).$(date +%d)"
# push
git push --set-upstream origin $branch_name

# gh-pages merge
git checkout gh-pages
git merge $branch_name

# push gh-pages
git push --set-upstream origin gh-pages