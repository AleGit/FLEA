#!/bin/bash

# build a binary
# ==============================================================
# Since `Sources/main.swift` and `Tests/LinuxMain.swift` would
# clash on Linux when the tests are build, this script builds an
# executable by copying `main.swift` into the `Sources` folder, then
# building the binary and removing `main.swift` after the build.
# (command line arguments are passed on)
#
# `$ Scripts/build.sh -c release -Xlinker -L/usr/local/lib`

# 3. remove `main.swift` from `Sources`
function finish {
  rm Sources/main.swift
}
trap finish EXIT

# 1. copy `main.swift` into the `Sources` folder
cp Scripts/main.swift Sources/main.swift

# 2. build the binary with arguments of the script, e.g.
#    * -c release
#    * -Xlinker -L/usr/local/lib
swift build "$@"


