#!/bin/bash

# swift build --clean
swift build -Xlinker -L/usr/local/lib
swift test
# swift test -s FLEATestSuite.WeakCollectionTests/testWeakStringCollection
