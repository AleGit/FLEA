#!/bin/bash

swift build --clean
Scripts/build.sh -c release -Xlinker -L/usr/local/lib

.build/release/FLEA --demo mgu
.build/release/FLEA --problem PUZ007-1