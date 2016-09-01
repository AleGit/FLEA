#!/bin/bash

# build a binary
# ==============================================================
# Since `Sources/main.swift` and `Tests/LinuxMain.swift` would 
# clash on Linux when the tests are build, this script builds an 
# binary by copying `main.swift` into the `Sources`folder , then 
# building the binary and removing `main.swift` after the build.
# `$ Scripts/build.sh -c release -Xlinker -L/usr/local/lib`

# 1. copy `main.swift` into the `Sources` folder
cp Scripts/main.swift Sources/main.swift

# 2. build the binary with arguments of the script, e.g.
#    * -c release
#    * -Xlinker -L/usr/local/lib
swift build "$@"

# 3. remove `main.swift` from `Sources`
rm Sources/main.swift