#!/usr/bin/env bash
#
# cli utilities

# prints usage for ellipsis
cli.usage() {
	cat <<-EOF
	Usage: ellipsis <command>

	Commands
      install     install new ellipsis module
      list        list available modules for install
      new         create a new ellipsis module
      pull        pull updates from upstream repositories
      push        push updates to local modules back to upstream repositories
      status      show status of local modules
      uninstall   uninstall ellipsis module
      help        show ellipsis help
      version     show ellipsis version
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
        uninstall|remove|rm|-)
            ellipsis.uninstall $2
            ;;
        list)
            ellipsis.list
            ;;
        new)
            ellipsis.new $2
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
