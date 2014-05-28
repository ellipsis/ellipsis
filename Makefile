# ellipsis - shell script package manager

all: test

gh-pages:
	brief

tag:
	@echo ELLIPSIS_VERSION=$(version) > src/version.bash
	@git add src/version.bash
	@git commit -m v$(version)
	@git tag v$(version)

test: deps/bats test/fixtures/dot-test/ellipsis.sh
	deps/bats/bin/bats test $(TEST_OPTS)

deps/bats:
	@mkdir -p deps
	git clone --depth 1 git://github.com/sstephenson/bats.git deps/bats

test/fixtures/dot-test/ellipsis.sh:
	git submodule init
	git submodule update

.PHONY: all gh-pages tag test
