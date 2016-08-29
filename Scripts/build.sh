#!/bin/bash

# build a binary
# ================================================================================

cp Scripts/main.swift Sources/main.swift
swift build "$@"
rm Sources/main.swift