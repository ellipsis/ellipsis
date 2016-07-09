# env.sh
# [POSIX]
#
# Functions to manage the env

# Call functions from the ellipsis API
env_api() {
    bash "$ELLIPSIS_BIN/ellipsis" api "$@"
}

# PATH helper, if exists, prepend, no duplication
env_prepend_path() {
    duplicates="$(echo "$PATH" | grep -Ec "(^|:)$1(:|$)")"
    if [ -d "$1" ] && [ "$duplicates" -eq 0 ]; then
        export PATH="$1:$PATH"
    fi
}

# PATH helper, if exists, append, no duplication
env_append_path() {
    duplicates="$(echo "$PATH" | grep -Ec "(^|:)$1(:|$)")"
    if [ -d "$1" ] && [ "$duplicates" -eq 0 ]; then
        export PATH="$PATH:$1"
    fi
}

env_init_ellipsis() {
    # Changable globals
    export ELLIPSIS_HOME
    export ELLIPSIS_PATH
    export ELLIPSIS_USER
    export ELLIPSIS_PACKAGES

    # Mainly for other scripts, as Ellipsis will be called from the wrapper
    # function
    env_append_path "$ELLIPSIS_BIN"
}

env_init() {
    packages="$@"

    # Init all packages if no package is given
    if [ -z "$packages" ]; then
        packages="ellipsis $(env_api ellipsis.list_packages)"
    fi

    for pkg in $packages; do
        # @TODO: ? add some output if run interactively?

        if [ "$pkg" = "Ellipsis" -o "$pkg" = "ellipsis" ]; then
            env_init_ellipsis
        else
            if env_api path.is_path "$pkg"; then
                PKG_PATH="$pkg"
                PKG_NAME="$(env_api pkg.name_from_path "$PKG_PATH")"
            else
                PKG_NAME="$pkg"
                PKG_PATH="$(env_api pkg.path_from_name "$PKG_NAME")"
            fi

            # Check if package exists
            if [ -d "$PKG_PATH" -a -f "$PKG_PATH/ellipsis.sh" ]; then

                # Extract init function
                pkg_init="$(bash -c "source $PKG_PATH/ellipsis.sh; declare -f pkg.init")"
                pkg_init="$(echo "$pkg_init" | sed 's/pkg.init/pkg_init/')"
                eval "$pkg_init"

                if hash "pkg_init" 2>&1 >/dev/null; then
                    cwd="$(pwd)"
                    cd "$PKG_PATH"

                    pkg_init

                    cd "$cwd"
                    unset -f pkg_init
                fi

                unset pkg_init
            fi

            unset PKG_PATH
            unset PKG_NAME
        fi
    done

    # Clean up env
    env_clean_up
}

# Keep the environment as clean as possible
env_clean_up() {
    unset -f env_api
    unset -f env_prepend_path
    unset -f env_append_path
    unset -f env_init_ellipsis
    unset -f env_init
    unset -f env_clean_up
}

# Special wrapper function to catch init (env) commands. This wrapper makes it
# possible to call the init hooks from within the current shell
ellipsis() {
    case $1 in
        init)
            # Remove init from $@
            shift

            # Source ellipsis with current shell
            . "$ELLIPSIS_PATH/init.sh"
            ;;
        *)
            # Run ellipsis with bash
            # !! Use ELLIPSIS_PATH and not ELLIPSIS_BIN !
            "$ELLIPSIS_PATH/bin/ellipsis" "$@"
            ;;
    esac
}
