# ellipsis - shell script package manager

all: test

gh-pages:
	brief

tag:
	@echo ELLIPSIS_VERSION=$(version) > src/version.bash
	@git add src/version.bash
	@git commit -m v$(version)
	@git tag v$(version)

stag:
	@echo ELLIPSIS_VERSION=$(version) > src/version.bash
	@git add src/version.bash
	@git commit -m v$(version)
	@git tag -s v$(version)

# Run test suite
test: deps/bats test/fixtures/dot-test/ellipsis.sh
	deps/bats/bin/bats test $(TEST_OPTS)

test/%: deps/bats test/fixtures/dot-test/ellipsis.sh
	deps/bats/bin/bats $@.bats $(TEST_OPTS)

deps/bats:
	@mkdir -p deps
	git clone --depth 1 --branch v1.7.0 https://github.com/bats-core/bats-core.git deps/bats

test/fixtures/dot-test/ellipsis.sh:
	git submodule init
	git submodule update


# Docker integration
# ------------------

# Build docker image
docker_build:
	docker build --build-arg USER=$(USER) -t ellipsis:latest .

# Run test suite in docker
docker_test_suite:
	docker run --rm -ti \
		-e ELLIPSIS_PATH=/home/$(USER)/.ellipsis \
		-v "$(PWD):/home/$(USER)/.ellipsis" \
		-e ELLIPSIS_PACKAGES=/home/$(USER)/.ellipsis_packages \
		ellipsis:latest

# Interactive devel ellipsis and dot files
docker_run:
	docker run --rm -ti \
		-e ELLIPSIS_PATH=/home/$(USER)/.ellipsis \
		-v "$(PWD):/home/$(USER)/.ellipsis" \
		-e ELLIPSIS_PACKAGES=/home/$(USER)/.ellipsis_packages \
		-v "$(ELLIPSIS_PACKAGES):/ellipsis_repos:ro" \
		ellipsis:latest bash

# Interactive devel ellipsis only
docker_dev_ellipsis:
	docker run --rm -ti \
		-e ELLIPSIS_PATH=/home/$(USER)/.ellipsis \
		-v "$(PWD):/home/$(USER)/.ellipsis" \
		-e ELLIPSIS_PACKAGES=/home/$(USER)/.ellipsis_packages \
		ellipsis:latest bash

# Interactive devel dot-files only
docker_dev_packages:
	docker run --rm -ti \
		-e ELLIPSIS_PACKAGES=/home/$(USER)/.ellipsis_packages \
		-v "$(ELLIPSIS_PACKAGES):/ellipsis_repos:ro" \
		ellipsis:latest bash


.PHONY: all gh-pages tag test
