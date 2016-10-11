# pkg.bash
#
# Ellipsis package interface. Encapsulates various useful functions for working
# with packages.

load fs
load git
load hooks
load log
load path
load utils

# Split name/branch to use
pkg.split_name() {
    echo ${1//@/ }
}

# Strip leading dot- from package name.
pkg.name_stripped() {
    echo $1 | sed -e "s/^dot-//"
}

# Convert package name to path.
pkg.path_from_name() {
    echo "$ELLIPSIS_PACKAGES/$1"
}

# Convert package path to name, stripping any leading dots.
pkg.name_from_path() {
    echo "${1##*/}" | sed -e "s/^\.//"
}

# Pull name out as last path component of url
pkg.name_from_url() {
    echo "$1" | rev | cut -d '/' -f 1 | rev
}

# Get user from github-user/name shorthand syntax.
pkg.user_from_shorthand() {
    echo "$1" | cut -d '/' -f1
}

# Get name from github-user/name shorthand syntax.
pkg.name_from_shorthand() {
    echo "$1" | cut -d '/' -f2
}

# Set PKG_NAME, PKG_PATH. If $1 looks like a path it's assumed to be
# PKG_PATH and not PKG_NAME, otherwise assume PKG_NAME.
pkg.set_globals() {
    if path.is_path "$1"; then
        PKG_PATH="$1"
        PKG_NAME="$(pkg.name_from_path "$PKG_PATH")"
    else
        PKG_NAME="$1"
        PKG_PATH="$(pkg.path_from_name "$PKG_NAME")"
    fi
}

# Setup the package env (vars/hooks)
pkg.env_up() {
    pkg.set_globals "${1:-"$PKG_PATH"}"

    # Exit if we're asked to operate on an unknown package.
    if [ ! -d "$PKG_PATH" ]; then
        log.fail "Unkown package $PKG_NAME, $(path.relative_to_home "$PKG_PATH") missing!"
        exit 1
    fi

    # Source ellipsis.sh if it exists to setup a package's hooks.
    if [ -f "$PKG_PATH/ellipsis.sh" ]; then
        source "$PKG_PATH/ellipsis.sh"
    fi
}

# List symlinks associated with package.
pkg.list_symlinks() {
    for file in $(fs.list_symlinks); do
        if [[ "$(readlink "$file")" == *packages/$PKG_NAME* ]]; then
            echo "$file"
        fi
    done
}

# Print file -> symlink mapping
pkg.list_symlink_mappings() {
    for file in $(fs.list_symlinks); do
        local link=$(readlink $file)

        if [[ "$link" == *packages/$PKG_NAME* ]]; then
            echo "$(path.relative_to_packages $link) -> $(path.relative_to_home $file)";
        fi
    done
}

# Run command inside PKG_PATH.
pkg.run() {
    local cwd="$(pwd)"

    # change to package dir
    cd "$PKG_PATH"

    # run command
    "$@"

    # keep return value
    local return_code="$?"

    # return after running command
    cd "$cwd"

    return "$return_code"
}

# run hook if it's defined, otherwise use default implementation
pkg.run_hook() {
    # Prevent unknown hooks from running
    if ! utils.cmd_exists hooks.$1; then
        log.fail "Unknown hook!"
        exit 1
    fi

    # Run packages's hook. Additional arguments are passed as arguments to
    # command.
    if utils.cmd_exists "pkg.$1"; then
        pkg.run "pkg.$1" "${@:2}"
    else
        pkg.run "hooks.$1" "${@:2}"
    fi
}

# Clear globals, hooks.
pkg.env_down() {
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
