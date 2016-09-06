#!/bin/bash

swift build --clean
Scripts/build.sh -c release
.build/release/FLEA --demo mgu
.build/release/FLEA --problem PUZ001-1 PUZ002-1