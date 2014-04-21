#!/usr/bin/env bash
#
# ellipsis cli

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
    list           list installed modules
    available      list modules available for install
    new            create a new module
    pull           git pull all modules
    push           git push all modules
    status         show status of all modules
	EOF
}

# prints ellipsis version
cli.version() {
    local cwd="$(pwd)"
    cd $HOME/.ellipsis

    local version=1.0.4
    local sha1=$(git rev-parse --short HEAD)
    echo -e "\033[1mv$version\033[0m ($sha1)"

    cd $cwd
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
        list|ls|installed)
            ellipsis.list
            ;;
        available)
            ellipsis.available
            ;;
        new)
            ellipsis.new $2
            ;;
        status|st)
            ellipsis.each git.status
            ;;
        pull|update|up)
            ellipsis.each git.pull
            ;;
        push)
            ellipsis.each git.push
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
