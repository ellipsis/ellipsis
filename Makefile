# ellipsis - shell script package manager

all: test

test: deps/bats
	deps/bats/bin/bats $(BATS_OPTS) test

tag:
	@echo ELLIPSIS_VERSION=$(version) > src/version.sh
	@git add src/version.sh
	@git commit -m v$(version)
	@git tag v$(version)

deps/bats:
	@mkdir -p deps
	git clone --depth 1 git://github.com/sstephenson/bats.git deps/bats

deps/jshon:
	@mkdir -p deps
	git clone --depth 1 git://github.com/keenerd/jshon deps/jshon
	cd deps/jshon; make

.PHONY: all tag test
