#!/bin/sh

mkdir -p bin
nim c $@ --nimcache=$(pwd)/.nimcache --debugger:native --out:bin/texture_load -p=$(pwd)/../../ texture_load.nim
nim c $@ --nimcache=$(pwd)/.nimcache --debugger:native --out:bin/atlas_load -p=$(pwd)/../../ atlas_load.nim
nim c $@ --nimcache=$(pwd)/.nimcache --debugger:native --out:bin/namedatlas_load -p=$(pwd)/../../ namedatlas_load.nim
nim c $@ --nimcache=$(pwd)/.nimcache --debugger:native --out:bin/tilemaps_load -p=$(pwd)/../../ tilemaps_load.nim
