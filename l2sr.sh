#!/bin/bash

path="DerivedData/Lisp2Swift/Build/Products/Debug"
$path/Lisp2Swift $@ > test.swift
swift -suppress-warnings test.swift
