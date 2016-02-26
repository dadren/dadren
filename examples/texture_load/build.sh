#!/bin/sh

mkdir -p bin
nim c $@ --nimcache=$(pwd)/.nimcache --debugger:native --out:bin/namedatlas_load -p=$(pwd)/../../ namedatlas_load.nim
