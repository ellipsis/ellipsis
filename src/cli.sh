#!/usr/bin/env bash
#
# cli utilities

# prints usage for ellipsis
cli.usage() {
    cat <<-EOF
Usage: ellipsis <command>
  Options:
    -h, --help     show help
    -v, --version  show version

  Commands:
    install        install new module
    uninstall      uninstall module
    list           list available modules for install
    new            create a new module
    pull           git pull all modules
    push           git push all modules
    status         show status of all modules
	EOF
}

# prints ellipsis version
cli.version() {
    sha=$(git rev-parse --short HEAD)
    echo "v1.0.2 ($sha)"
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
            if [ "$1" ]; then
                echo ellipsis: invalid command -- $1
                cli.usage >&2
                exit 1
            else
                cli.usage
            fi
            ;;
    esac
}
