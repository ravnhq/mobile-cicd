#!/usr/bin/env bash

version="$1"

if [[ -n $(git status --porcelain) ]]; then
  echo "Git workspace is not empty, aborting..."
  exit 1
fi

echo "${version}" > .version
perl -pi -e "s/(readonly VERSION=).*/\${1}\"${version}\"/" fastlanew

git add .version fastlanew
git commit -m "chore: Bump to version ${version}" && git tag "${version}"
