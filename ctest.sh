#!/bin/bash

# calls swift build and swift test [-s .../...] to
# run all tests, one test class or one test only.

swift build --clean
./tests.sh $1 $2