#!/bin/bash

function finish {
  rm Tests/FLEATests/DemoTests.swift
}
trap finish EXIT

cp Scripts/XTests.swift Tests/FLEATests/DemoTests.swift

Scripts/tests.sh "$@"

