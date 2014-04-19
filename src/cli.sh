#!/usr/bin/env bash

cli.usage() {
	cat <<-EOF
	Usage: ellipsis <command>

	Commands
	  install     install new modules
	  push        push updates to local modules back to upstream repositories
	  pull        pull updates from upstream repositories
	  status      report status of local modules
	  help        print this message and exit
	EOF
}

cli.version() {
    tag=$(git describe --tags --abbrev=0)
    sha=$(git rev-parse --short HEAD)
    echo "$tag ($sha)"
}

cli.run() {
    case $1 in
        install|add|in|+)
            ellipsis.install $2
        ;;
        status|st)
            ellipsis.do git.status
        ;;
        pull|update|up)
            ellipsis.do git.pull
        ;;
        push)
            ellipsis.do git.push
        ;;
        help)
            cli.usage
        ;;
        version)
            cli.version
        ;;
        *)
            cli.usage >&2
            exit 1
        ;;
    esac
}
