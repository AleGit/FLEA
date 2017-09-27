#!/bin/bash

# $ Scripts/tests.sh [<1> [<2>]]
# calls `swift test -Xlinker -L/usr/local/libe [-s <1>Tests[/test<2>]]
# to run all tests, one test class or one test only:

# swift test -Xlinker -L/usr/local/lib
# swift test -Xlinker -L/usr/local/lib -s FLEATests.NodeTests/
# swift test -Xlinker -L/usr/local/lib -s FLEATests.NodeTests/testInit

# ================================================================================
# https://github.com/apple/swift-package-manager/blob/master/CHANGELOG.md
# * It is no longer necessary to run `swift build` before running `swift test` (it
#   will always regenerates the build manifest when necessary). In addition, it
#   now accepts (and requires) the same `-Xcc`, etc. options as are used with
#   `swift build`.
# ================================================================================

if [ "$1" = "--help" ]
then
  echo ${0}' considers up to two arguments.'
  echo 'a) '${0} '                 => swift test'
  echo 'b) '${0} '<regex>          => swift test --filter <regex>'
  echo 'c) '${0} '<Class> <Func>   => swift test --filter <Class>Tests/test<Func>'
elif [ -n "$2" ]
then
  T="FLEATests.${1}Tests/test${2}"
  echo "START: swift test --filter ${T}"
  swift test -Xlinker -L/usr/local/lib --filter $T
  echo "DONE: swift test --filter ${T}"
elif [ -n "$1" ]
then
  # T="FLEATests.${1}Tests"
  echo "START: swift test --filter ${1}"
  swift test -Xlinker -L/usr/local/lib --filter $1
  echo "DONE: swift test --filter ${1}"
else
  # swift test -Xswiftc -warnings-as-errors -Xlinker -L/usr/local/lib
  swift test -Xlinker -L/usr/local/lib
  # swift test -Xswiftc -suppress-warnings -Xlinker -L/usr/local/lib
fi
