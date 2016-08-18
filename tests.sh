#!/bin/bash

# calls swift build and swift test [-s .../...] to
# run all tests, one test class or one test only.

swift build -Xlinker -L/usr/local/lib

if [ "$1" = "--help" ]
then
  echo ${0}' considers up to two arguments.'
  echo ${0} '<1> <2>'
  echo '<1>' the test class name without the suffix 'Tests'
  echo '<2>' the test name without the perfix 'test'
  echo '0 => swift test'
  echo '1 => swift test -s FLEATests.<1>Tests'
  echo '2 => swift test -s FLEATests.<1>Tests/test<2>'
  echo e.g. \$ ${0} Node Init
  echo '=> swift test -s FLEATests.NodeTests/testInit'
elif [ -n "$2" ]
then
  T="FLEATests.${1}Tests/test${2}"
  echo "swift test -s ${T}"
  swift test -s $T
elif [ -n "$1" ]
then
  T="FLEATests.${1}Tests"
  echo "swift test -s ${T}"
  swift test -s $T
else
  swift test
fi
