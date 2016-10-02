
make: stage
	nim c --nimcache=.nimcache --debugger:native --out:bin/example -p=./../../ example.nim

profile: stage
	nim c --nimcache=.nimcache --profiler:on --stackTrace:on --debugger:native --out:bin/example -p=./../../ example.nim

release: stage
	nim c --nimcache=.nimcache -d:release --out:bin/example -p=./../../ example.nim

stage:
	mkdir -p bin
