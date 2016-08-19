#!/bin/sh

# _move_ local tag 1.0.1 to newest commit

git tag -d 1.0.1
git tag 1.0.1
git tag
