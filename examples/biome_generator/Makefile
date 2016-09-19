
make: stage
	nim c $@ --nimcache=$(pwd)/.nimcache --debugger:native --out:bin/example -p=$(pwd)/../../ example.nim

release: stage
	nim c $@ --nimcache=$(pwd)/.nimcache -d:release --out:bin/example -p=$(pwd)/../../ example.nim

stage:
	mkdir -p bin
