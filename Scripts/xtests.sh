#!/bin/bash

cp Scripts/XTests.swift Tests/FLEATests/XTests.swift

Scripts/tests.sh "$@"

rm Tests/FLEATests/XTests.swift