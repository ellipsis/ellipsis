# default: run tests
all: test

## various functions

# run tests
.PHONY: test
test: deps/bats
	deps/bats/bin/bats $(BATS_OPTS) test

# create a new git tag
.PHONY: tag
tag:
	@echo ELLIPSIS_VERSION=$(version) > src/version.sh
	@git add src/version.sh
	@git commit -m v$(version)
	@git tag v$(version)

# bats is used for testing
deps/bats:
	@mkdir -p deps
	git clone --depth 1 git://github.com/sstephenson/bats.git deps/bats
