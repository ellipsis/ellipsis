all : test

test :
	bats tests

tag :
	@echo ELLIPSIS_VERSION=$(version) > src/version.sh
	@git add src/version.sh
	@git commit -m v$(version)
	@git tag v$(version)
