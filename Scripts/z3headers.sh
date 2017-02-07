#!/bin/bash

# 'Z3' headers workaround for Linux

# yices and tptpParsing install their headers in
# - `/usr/local/include` on Linux and macOS

# Z3 installs its headers in
# - `/usr/include` on Linux
# - `/usr/local/include` on macOS

# A Swift system module stores a fixed path to a library header.
# module CZ3Api [system] {
#   header "/usr/local/include/z3.h"
#   link "z3"
#   export *
# }

# Hence on Linux the headers have to be linked into `/usr/local/include`

name=`uname -s`

if [ "${name}" == "Darwin" ]; then
    # Do something under Mac OS X platform
    echo "${name}: z3 headers already in '/usr/local/include/''"
elif [ "${name}" == "Linux" ]; then
    # Do something under GNU/Linux platform
    echo "${name}: z3 headers in '/usr/include/'"
    sudo find /usr/include -name "z3*.h" -type f -ls -exec ln -s -t /usr/local/include {} \;
    echo "${name}: z3 header links in '/usr/local/include/'"
else
    echo "Unknown ${name}"
fi

find /usr/local/include -name "z3*.h" -type f -ls

