# cli.bash
#
# Command line interface for ellipsis.

load ellipsis
load fs
load os
load path
load registry
load git
load msg

# prints usage for ellipsis
cli.usage() {
    cat <<-EOF
Usage: ellipsis <command>
  Options:
    -h, --help     show help
    -v, --version  show version

  Commands:
    init       source init code
    new        create a new package
    edit       edit an installed package
    add        add new dotfile to package
    remove     remove a files form a package
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
    info       show ellipsis info
EOF
}

# prints ellipsis version
cli.version() {
    local cwd="$(pwd)"
    cd "$ELLIPSIS_PATH"

    local sha1="$(git.sha1)"
    msg.print "\033[1mv$ELLIPSIS_VERSION\033[0m ($sha1)"

    cd "$cwd"
}

cli.info() {
    cli.version
    msg.print "  Home: $ELLIPSIS_HOME"
    msg.print "  User: $ELLIPSIS_USER"
    msg.print "  Init: $ELLIPSIS_INIT"
    msg.print "  Path: $ELLIPSIS_PATH"
    msg.print "  Config: $ELLIPSIS_CCONFIG"
    msg.print "  Packages: $ELLIPSIS_PACKAGES"
}

cli.load_config() {
    local config_paths=()

    if [ -n "$ELLIPSIS_CONFIG" ]; then
        config_paths+=("$ELLIPSIS_CONFIG")
    fi

    if [ -n "$XDG_CONFIG_HOME" ]; then
        config_paths+=("$XDG_CONFIG_HOME/ellipsisrc")
        config_paths+=("$XDG_CONFIG_HOME/ellipsis/ellipsisrc")
    fi

    config_paths+=("$HOME/.ellipsisrc")
    config_paths+=("$HOME/.ellipsis/ellipsisrc")

    ELLIPSIS_CCONFIG="$(fs.first_found "${config_paths[@]}")"
    if [ -n "$ELLIPSIS_CCONFIG" ]; then
        ELLIPSIS_CCONFIG="$(path.abs_path "$ELLIPSIS_CCONFIG")"
        source "$ELLIPSIS_CCONFIG"
    fi
}

# run ellipsis
cli.run() {
    cli.load_config

    case "$1" in
        api)
            ellipsis.api "${@:2}"
            ;;
        init)
            # Reserved
            ;;
        new)
            ellipsis.new $2
            ;;
        edit)
            ellipsis.edit $2
            ;;
        add)
            ellipsis.add "${@:2}"
            ;;
        remove|rm)
            ellipsis.remove "${@:2}"
            ;;
        install|in)
            ellipsis.install "${@:2}"
            ;;
        uninstall|un)
            ellipsis.uninstall "${@:2}"
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
        info)
            cli.info
            ;;
        *)
            if [ $# -gt 0 ]; then
                msg.print "ellipsis: invalid command -- $1"
            fi
            cli.usage
            return 1
            ;;
    esac
}
