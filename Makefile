# ellipsis - shell script package manager

all: test

gh-pages:
	brief

tag:
	@echo ELLIPSIS_VERSION=$(version) > src/version.sh
	@git add src/version.sh
	@git commit -m v$(version)
	@git tag v$(version)

test: deps/bats
	deps/bats/bin/bats test $(TEST_OPTS)

deps/bats:
	@mkdir -p deps
	git clone --depth 1 git://github.com/sstephenson/bats.git deps/bats

.PHONY: all tag test
