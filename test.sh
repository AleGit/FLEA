#!/bin/bash

# swift build --clean
swift build -Xlinker -L/usr/local/lib

if [ "$1" = "--help" ]
then
  echo ${0}' considers up to two arguments.'
  echo ${0} '<1> <2>'
  echo '<1>' the test class name without the suffix 'Tests'
  echo '<2>' the test name without the prfix 'test'
  echo '0 => swift test'
  echo '1 => swift test FLEATestSuite.<1>Tests'
  echo '2 => swift test FLEATestSuite.<1>Tests/test<2>'
elif [ -n "$2" ]
then
  T="FLEATestSuite.${1}Tests/test${2}"
  echo "swift test -s ${T}"
  swift test -s $T
elif [ -n "$1" ]
then
  T="FLEATestSuite.${1}Tests"
  echo "swift test -s ${T}"
  swift test -s $T
else
  swift test
fi
