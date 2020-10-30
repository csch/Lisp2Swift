#!/bin/bash

args=("$@")

swift ./Lisp2Swift/main.swift $args > test.swift
swift test.swift
