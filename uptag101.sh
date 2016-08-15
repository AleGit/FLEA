#!/bin/sh

# 'move' local tag to newest commit

git tag -d 1.0.1
git tag 1.0.1
git tag
