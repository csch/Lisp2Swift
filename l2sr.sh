#!/bin/bash

pathPrefix="`ls -d ~/Library/Developer/Xcode/DerivedData/Lisp2Swift*`"
path="$pathPrefix/Build/Products/Debug"
$path/Lisp2Swift $@ > l2s.swift
swift -suppress-warnings l2s.swift
