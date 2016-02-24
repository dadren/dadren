#!/bin/sh

mkdir -p bin
nim c $@ --nimcache=$(pwd)/.nimcache --debugger:native --out:bin/texture_load -p=$(pwd)/../../ texture_load.nim
