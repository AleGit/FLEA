#!/bin/bash

Scripts/build_release.sh
Scripts/build_debug.sh

rm Sources/main.swift
clear

echo ""
echo "=== TESTS ==="
Scripts/tests.sh Demo Simple

echo ""
echo "=== DEBUG ==="
.build/debug/FLEA --demo simple

echo ""
echo "=== RELEASE"
.build/release/FLEA --demo simple
