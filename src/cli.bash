# cli.bash
#
# Command line interface for ellipsis.

load ellipsis
load registry

# prints usage for ellipsis
cli.usage() {
    cat <<-EOF
Usage: ellipsis <command>
  Options:
    -h, --help     show help
    -v, --version  show version

  Commands:
    new        create a new package
    edit       edit an installed package
    install    install new package
    uninstall  uninstall package
    unlink     unlink package
    broken     list any broken symlinks
    clean      rm broken symlinks
    list       list installed packages
    links      show symlinks installed by package(s)
    pull       git pull package(s)
    push       git push package(s)
    status     show status of package(s)
    publish    publish package to repository
    search     search package repository
	EOF
}

# prints ellipsis version
cli.version() {
    local cwd="$(pwd)"
    cd $ELLIPSIS_HOME/.ellipsis

    local sha1=$(git rev-parse --short HEAD)
    echo -e "\033[1mv$ELLIPSIS_VERSION\033[0m ($sha1)"

    cd $cwd
}

# run ellipsis
cli.run() {
    case "$1" in
        new)
            ellipsis.new $2
            ;;
        edit)
            ellipsis.edit $2
            ;;
        install|in|add)
            ellipsis.install $2
            ;;
        uninstall|remove|rm)
            ellipsis.uninstall $2
            ;;
        broken)
            ellipsis.broken $2
            ;;
        clean)
            ellipsis.clean $2
            ;;
        unlink)
            ellipsis.unlink $2
            ;;
        list|ls|installed)
            ellipsis.installed
            ;;
        links|symlinks)
            ellipsis.symlinks $2
            ;;
        status|st)
            ellipsis.status $2
            ;;
        pull|update|up)
            ellipsis.pull $2
            ;;
        push)
            ellipsis.push $2
            ;;
        available)
            registry.available
            ;;
        publish)
            registry.publish $2
            ;;
        search)
            registry.search $2
            ;;
        help|--help|-h)
            cli.usage
            ;;
        version|--version|-v)
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
