#!/bin/bash

# build an run FLEA

swift package clean
Scripts/build_release.sh


# .build/release/FLEA --demo mgu
.build/release/FLEA --demo succ
# .build/release/FLEA --problem PUZ001-1
# .build/release/FLEA --problem PUZ007-1