#!/bin/bash

# delete all compiled and linked project products

pwd
swift build --clean
Scripts/tests.sh $1 $2
