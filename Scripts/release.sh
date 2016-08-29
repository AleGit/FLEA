#!/bin/bash

# 
# ================================================================================

cp Scripts/main.swift Sources/main.swift
swift build -c release
rm Sources/main.swift