# default: run tests
all: test

# run tests
test: deps/bats
	deps/bats/bin/bats $(BATS_OPTS) test

# generate documentation
docs: deps/shocco
	@for sh in src/*; do \
		deps/shocco/shocco.sh src/$$sh > docs/$$sh \
	done


# create a new git tag
tag:
	@echo ELLIPSIS_VERSION=$(version) > src/version.sh
	@git add src/version.sh
	@git commit -m v$(version)
	@git tag v$(version)

# deps

# bats is used for testing
deps/bats: deps
	git clone --depth 1 git://github.com/sstephenson/bats.git deps/bats

# shocco is used for documentation generation
deps/shocco:
	git clone --depth 1 git://github.com/rtomayko/shocco.git deps/shocco
	chmod +x deps/shocco/shocco.sh
	pip install pygments -U
