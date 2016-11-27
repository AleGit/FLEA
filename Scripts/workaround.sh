#!/bin/bash

# Z3 installs its headers in
# - `/usr/include` on Linux
# - `/usr/local/include` on macOS

# A Swift system module stores a fixed path to a library header.
# module CZ3Api [system] {
#   header "/usr/local/include/z3.h"
#   link "z3"
#   export *
# }

name=`uname -s`

if [ "${name}" == "Darwin" ]; then
    # Do something under Mac OS X platform
    echo "${name}"
elif [ "${name}" == "Linux" ]; then
    # Do something under GNU/Linux platform
    echo "${name} workaround"
    sudo find /usr/include -name "z3*h" -type f -ls -exec ln -s -t /usr/local/include {} \;
    echo "${name} workaround completed"
else
    echo "Unknown ${name}"
fi

find /usr/local/include -name "z3*h" -type f -ls

