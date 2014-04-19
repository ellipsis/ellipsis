#!/usr/bin/env bash
#
# cli utilities

# prints usage for ellipsis
cli.usage() {
	cat <<-EOF
	Usage: ellipsis <command>

	Commands
	  install     install a new ellipsis module
	  list        list available modules
	  push        push updates to local modules back to upstream repositories
	  pull        pull updates from upstream repositories
	  status      report status of local modules
	  help        print this message and exit
	  version     print ellipsis version
	EOF
}

# prints ellipsis version
cli.version() {
    tag=$(git describe --tags --abbrev=0)
    sha=$(git rev-parse --short HEAD)
    echo "$tag ($sha)"
}

# run ellipsis
cli.run() {
    case "$1" in
        install|add|in|+)
            ellipsis.install $2
            ;;
        list)
            ellipsis.list
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
        help|--help|-h)
            cli.usage
            ;;
        version|--version|-v)
            cli.version
            ;;
        *)
            cli.usage >&2
            exit 1
            ;;
    esac
}
