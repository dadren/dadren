#!/bin/sh

mkdir -p bin
nim c $@ --nimcache=$(pwd)/.nimcache --debugger:native --out:bin/example -p=$(pwd)/../../ example.nim
