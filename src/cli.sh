#!/usr/bin/env bash
#
# cli.sh
# Command line interface for ellipsis.

# Source globals if they haven't been yet
if [[ $ELLIPSIS_GLOBALS -ne 1 ]]; then
    source $(dirname "${BASH_SOURCE[0]}")/globals.sh
fi

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
    links          list symlinks installed globally or for a module
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

    local sha1=$(git rev-parse --short HEAD)
    echo -e "\033[1mv$ELLIPSIS_VERSION\033[0m ($sha1)"

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
        links|symlinks)
            if [ "$2" ]; then
                ellipsis.symlinks $2
            else
                ellipsis.symlinks
            fi
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
        --help|-h)
            cli.usage
            ;;
        --version|-v)
            cli.version
            ;;
        *)
            if [ $# -gt 0 ]; then
                echo ellipsis: invalid command -- $1
            fi
            cli.usage
            return 1
            ;;
    esac
}
