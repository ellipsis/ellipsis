<h1>Developping Ellipsis</h1>

<h2>Ellipsis on Docker</h2>

There are a bunch of `make` commands to help you start:
```
# Build a local dev image
make docker_build

# Run test suite in docker
make docker_test_suite

# Get an interactive shell
make docker_dev_ellipsis
```

Make will display the docker commands it will execute. But you can also directly use docker cli:

```bash
# Build anonymous image
docker build --build-arg USER=anon -t ellipsis:latest .

# Get inside:
docker run --rm -ti ellipsis:latest bash

# To run test suite (no args)
docker run --rm -t ellipsis:latest

# To run tests suite with options
docker run --rm -t -e TEST_OPTS='--verbose-run bin' ellipsis:latest

# Or directly call ellipsis
docker run --rm -ti ellipsis:latest bash -c '$ELLIPSIS_PATH/bin/ellipsis help'
```

<h2>Dot files on Docker</h2>

For developping your own files, and test deployments, you may prefer to use:
```bash
# Get an interactive shell with your dotfiles
make docker_dev_packages 

# If you want to both test ellipsis and your dott files
make docker_run 
```

You can optionnaly enable ellipsis as shell manager:
```bash
$ $ELLIPSIS_PATH/bin/ellipsis help
$ $ELLIPSIS_PATH/bin/ellipsis link ellipsis
$ bash
$ ellipsis help
```

You can also deploy from the url this way:

TODO

To test your dot-files deployments:

TODO

<h2>Github Integration</h2>

This project takes advantage of Github integrations:
```
.github/
|-- ISSUE_TEMPLATE.md
|-- PULL_REQUEST_TEMPLATE.md
`-- workflows
    `-- ci.yml
```

To test Github Actions, you can take advantage of [act](https://github.com/nektos/act):
```
$ act push
```

