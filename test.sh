#!/bin/bash

swift build --clean
swift build -Xlinker -L/usr/local/lib
# .build/debug/FLEA --demo mgu
swift test
