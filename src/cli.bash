# cli.bash
#
# Command line interface for ellipsis.

load ellipsis
load fs
load os
load path
load registry
load git

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
    add        add new dotfile to package
    install    install new package
    uninstall  uninstall package
    link       link package
    unlink     unlink package
    broken     list any broken symlinks
    clean      rm broken symlinks
    installed  list installed packages
    links      show symlinks installed by package(s)
    pull       git pull package(s)
    push       git push package(s)
    status     show status of package(s)
    publish    publish package to repository
    search     search package repository
    strip      strip . from filenames
	EOF
}

# prints ellipsis version
cli.version() {
    local cwd="$(pwd)"
    cd "$ELLIPSIS_PATH"

    local sha1="$(git.sha1)"
    echo -e "\033[1mv$ELLIPSIS_VERSION\033[0m ($sha1)"

    cd "$cwd"
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
        add)
            ellipsis.add "${@:2}"
            ;;
        install|in)
            ellipsis.install "${@:2}"
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
        link)
            ellipsis.link $2
            ;;
        unlink)
            ellipsis.unlink $2
            ;;
        links|symlinks)
            ellipsis.links $2
            ;;
        installed|list|ls)
            ellipsis.installed
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
        strip)
            fs.strip_dot $2
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
