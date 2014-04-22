all: test

test: scripts/bats/bin/bats
	scripts/bats/bin/bats $(BATS_OPTS) tests

scripts/bats/bin/bats:
	git clone --depth 1 https://github.com/sstephenson/bats scripts/bats

tag:
	@echo ELLIPSIS_VERSION=$(version) > src/version.sh
	@git add src/version.sh
	@git commit -m v$(version)
	@git tag v$(version)
