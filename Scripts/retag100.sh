#!/bin/sh

# _move_ local and remote tag 1.0.0 to newest commit.

git tag -d 1.0.0
git push origin :refs/tags/1.0.0
git tag 1.0.0
git push --tag
git tag
