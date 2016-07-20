#!/bin/bash

# swift build --clean
swift build -Xlinker -L/usr/local/lib

if [ -n "$1" ]; then
  echo $0 $1
  swift test -s "$1"
else
  swift test
fi
# swift test -s FLEATestSuite.WeakCollectionTests/testWeakStringCollection
