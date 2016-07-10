# env.sh
# [POSIX]
#
# Functions to manage the env

# Call functions from the ellipsis API
# Note: this is relatively slow, and should be avoided if possible
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
    # Changeable globals
    export ELLIPSIS_HOME
    export ELLIPSIS_PATH
    export ELLIPSIS_USER
    export ELLIPSIS_PACKAGES

    # Mainly for other scripts, as Ellipsis will be called from the wrapper
    # function
    env_append_path "$ELLIPSIS_BIN"
}

env_init_pkg() {
    pkg="$1"

    if [ -d "$pkg" ]; then
        PKG_PATH="$pkg"
        PKG_NAME="${PKG_PATH##*/}"
    else
        PKG_NAME="$pkg"
        PKG_PATH="$ELLIPSIS_PACKAGES/$PKG_NAME"
    fi

    # Check if package exists and has an init hook
    if [ -f "$PKG_PATH/ellipsis.sh" ]; then
        grep 'pkg.init' "$PKG_PATH/ellipsis.sh" 2>&1 >/dev/null
        if [ "$?" -eq 0 ]; then

            # Extract init function
            pkg_init="$(bash -c "source $PKG_PATH/ellipsis.sh; declare -f pkg.init")"
            pkg_init="$(echo "$pkg_init" | sed 's/pkg.init/pkg_init/')"
            eval "$pkg_init"

            command -v 'pkg_init' 2>&1 >/dev/null
            if [ "$?" -eq 0 ]; then
                cwd="$(pwd)"
                cd "$PKG_PATH"

                pkg_init

                cd "$cwd"
                unset -f pkg_init
            fi

            unset pkg_init
        fi
    fi

    unset pkg
    unset PKG_PATH
    unset PKG_NAME
}

env_init() {
    packages="$@"

    # Init all packages if no package is given
    if [ -z "$packages" ]; then
        packages="$(echo "$ELLIPSIS_PACKAGES"/*)"
        if [  "$packages" = "$ELLIPSIS_PACKAGES/*" ]; then
            packages='ellipsis'
        else
            packages="ellipsis $packages"
        fi
    fi

    for pkg in $packages; do
        # @TODO: ? add some output if run interactively?

        if [ "$pkg" = "Ellipsis" ] || [ "$pkg" = "ellipsis" ]; then
            env_init_ellipsis
        else
            env_init_pkg "$pkg"
        fi
    done

    # Clean up env
    unset packages
    env_clean_up
}

# Keep the environment as clean as possible
env_clean_up() {
    unset -f env_api
    unset -f env_init
    unset -f env_clean_up
    unset -f env_init_pkg
    unset -f env_append_path
    unset -f env_prepend_path
    unset -f env_init_ellipsis
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
