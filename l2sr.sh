#!/bin/sh

if [[ "$#" -gt 2 || "$1" == "--help" ]]; then
    echo "Usage: $0 [-f filename | '(lisp)']"
    exit 1
fi

l2s="build/Release/Lisp2Swift"

if [ ! -f "$l2s" ]; then
    echo "Run ./build.sh first"
    exit 1
fi
   
$l2s $@ > l2s.swift
swift -suppress-warnings l2s.swift
