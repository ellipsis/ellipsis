#!/usr/bin/env bash
#
# cli.sh
# Command line interface for ellipsis.

# Initialize ourselves if we haven't yet.
if [[ $ELLIPSIS_INIT -ne 1 ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")"/init.sh
fi

# Source deps.
load ellipsis
load epmi
load git
load github
load pkg
load utils

# prints usage for ellipsis
cli.usage() {
    cat <<-EOF
Usage: ellipsis <command>
  Options:
    -h, --help     show help
    -v, --version  show version

  Commands:
    install        install new package
    uninstall      uninstall package
    list           list installed packages
    links          list symlinks installed globally or for a package
    available      list packages available for install
    new            create a new package
    pull           git pull all packages
    push           git push all packages
    status         show status of all packages
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
        install|in|add)
            ellipsis.install $2
            ;;

        uninstall|remove|rm)
            ellipsis.uninstall $2
            ;;

        unlink)
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
            epmi.list_packages
            ;;

        search)
            epmi.search_packages $2
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
