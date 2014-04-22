all: test

test: scripts/bats/bin/bats
	scripts/bats/bin/bats tests

test_travis: scripts/bats/bin/bats
	ln -s /home/travis/build/zeekay/ellipsis /home/travis/.ellipsis
	scripts/bats/bin/bats --tap tests

scripts/bats/bin/bats:
	git clone https://github.com/sstephenson/bats scripts/bats

tag:
	@echo ELLIPSIS_VERSION=$(version) > src/version.sh
	@git add src/version.sh
	@git commit -m v$(version)
	@git tag v$(version)
