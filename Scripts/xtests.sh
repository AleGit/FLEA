#!/bin/bash

# 3. remove DemoTests.swift from Tests/FLEATests
function finish {
  # DemoTests.swift MUST NOT remain in Tests/FLEATests
  rm Tests/FLEATests/DemoTests.swift
}
# ensure cleanup
trap finish EXIT

# 1. copy DemoTests.swift into Tests/FLEATests temporarilly
cp Scripts/XTests.swift Tests/FLEATests/DemoTests.swift

# 2. run tests with eXtra eXpensive test cases
Scripts/tests.sh "$@"

