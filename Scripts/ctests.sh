#!/bin/bash

# delete all compiled and linked project products

swift build --clean
Scripts/tests.sh $1 $2
