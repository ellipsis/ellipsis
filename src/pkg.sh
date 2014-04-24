#!/usr/bin/env bash
#
# pkg.sh
# Ellipsis package interface. Encapsulates various useful functions for working
# with packages.


# Initialize ourselves if we haven't yet.
if [[ $ELLIPSIS_INIT -ne 1 ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")"/init.sh
fi

# List of hooks available to package authors.
PKG_HOOKS=(install uninstall unlink symlinks pull push status list)

# Convert package name to path.
pkg.name_to_path() {
    echo "$ELLIPSIS_PATH/packages/$1"
}

# Convert package path to name.
pkg.path_to_name() {
    # basename
    local basename=${1##*/}
    # strip any leading dots
    echo ${basename##*.}
}

# Set name/path appropriately. If $1 has a slash it's assumed to be PKG_PATH we
# should use and not PKG_NAME.
pkg.set_name_and_path() {
    if utils.has_slash "$1"; then
        PKG_PATH="$1"
        PKG_NAME="$(pkg.path_to_name $PKG_PATH)"
    else
        PKG_NAME="$1"
        PKG_PATH="$(pkg.name_to_path $PKG_NAME)"
    fi
}

# Initialize a package and it's hooks.
pkg.init() {
    pkg.set_name_and_path ${1:-$PKG_PATH}

    # source ellipsis.sh if it exists to initialize package hooks
    if [ -f "$PKG_PATH/ellipsis.sh" ]; then
        source "$PKG_PATH/ellipsis.sh"
    fi
}

# Find package's symlinks.
pkg.list_symlinks() {
    for file in $(utils.list_symlinks); do
        local link="$(readlink $file)"
        if [[ "$link" == *packages/$PKG_NAME* ]]; then
            echo "$(utils.strip_packages_dir $link) -> $(utils.relative_path $file)";
        fi
    done
}

pkg.symlinks() {
    pkg.list_symlinks | sort | column -t
}

# Run hook or command inside $PKG_PATH.
pkg.run() {
    local cwd="$(pwd)"

    # change to package dir
    cd "$PKG_PATH"

    # run hook or command
    case $1 in
        pkg.*)
            pkg.run_hook $1
            ;;
        *)
            $1
            ;;
    esac

    # return after running command
    cd "$cwd"
}

# run hook if it's defined, otherwise use default implementation
pkg.run_hook() {
    # Run packages's hook.
    if utils.cmd_exists $1; then
        $1
    else
        # Run default hook.
        case $1 in
            pkg.install)
                pkg.hooks.install
                ;;
            pkg.unlink)
                pkg.hooks.unlink
                ;;
            pkg.uninstall)
                pkg.hooks.uninstall
                ;;
            pkg.symlinks)
                pkg.hooks.symlinks
                ;;
            pkg.pull)
                pkg.hooks.pull
                ;;
            pkg.push)
                pkg.hooks.push
                ;;
            pkg.list)
                pkg.hooks.list
                ;;
            pkg.status)
                pkg.hooks.status
                ;;
            *)
                echo Unknown hook!
                ;;
        esac
    fi
}

# Clear globals, hooks.
pkg.del() {
    pkg._unset_vars
    pkg._unset_hooks
}

# Unset global packages.
pkg._unset_vars() {
    unset PKG_NAME
    unset PKG_PATH
}

# Unset any hooks that might have been defined by package.
pkg._unset_hooks() {
    for hook in ${PKG_HOOKS[@]}; do
        unset -f pkg.$hook
    done
}

# Hooks


# Symlink files in $PKG_PATH into $HOME
pkg.hooks.install() {
    ellipsis.link_files $PKG_PATH
}

# Remove package's symlinks in $HOME.
pkg.hooks.unlink() {
    for symlink in $(pkg.list_symlinks); do
        rm $symlink
    done
}

# Remove package's symlinks then remove package.
pkg.hooks.uninstall() {
    pkg.run_hook pkg.unlink
    rm -rf $PKG_PATH
}

# List packages symlinks in $HOME.
pkg.hooks.symlinks() {
    echo -e "\033[1m$PKG_NAME\033[0m"
    pkg.list_symlinks | sort
}

# Do git pull from package
pkg.hooks.pull() {
    pkg.run git.pull
}

# Do git push from package
pkg.hooks.push() {
    pkg.run git.push
}

# List repo status.
pkg.hooks.list() {
    pkg.run git.list
}

# List repo status if it's changed and show git diffstat.
pkg.hooks.status() {
    pkg.run git.status
}
