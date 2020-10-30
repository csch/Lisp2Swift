#!/bin/bash

args=("$@")

path="DerivedData/Lisp2Swift/Build/Products/Debug"
$path/Lisp2Swift $args > test.swift
swift test.swift
