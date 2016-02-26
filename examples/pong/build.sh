#!/bin/sh

mkdir -p bin
nim c $@ --nimcache=$(pwd)/.nimcache --debugger:native --out:bin/pong -p=$(pwd)/../../ pong.nim
