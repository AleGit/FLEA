#!/bin/sh

# 'move' local and remote tag 1.0.1
# to newest commit.

git tag -d 1.0.0
git push origin :refs/tags/1.0.0
git tag 1.0.0
git push --tag
git tag
