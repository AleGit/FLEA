#!/bin/bash

# delete all compiled and linked project products
# build and run tests
# the script uses the first two command line arguments
#
# $1 should be the name of a test class without suffix `Tests`, eg. `Trie` for class `TrieTests`
# $2 should be the name of a test function in $1, without the prefix `test`, e.g. `Unifiables` for function `testUnifiables`

swift build --clean
Scripts/tests.sh $1 $2
