# env.sh
# [POSIX]
#
# Functions to manage the env

# Call functions from the ellipsis API
# Note: this is relatively slow, and should be avoided if possible
env_api() {
    # Explicitly use bash by calling the bash scipt
    bash "$ELLIPSIS_BIN/ellipsis" api "$@"
}

# PATH helper, if exists, prepend, no duplication
env_prepend_path() {
    [ -d "$1" ] || {
        env_api log.error "Could not prepend '$1' to \$PATH, not a directory"
        return
    }

    # Remove $1 if it's already in the path to prevent duplicates
    PATH="${PATH//:$1/}"
    PATH="${PATH//:$1:/}"
    PATH="${PATH//$1:/}"

    export PATH="$1${PATH:+":$PATH"}"
}

# PATH helper, if exists, append, no duplication
env_append_path() {
    [ -d "$1" ] || {
        env_api log.error "Could not append '$1' to \$PATH, not a directory"
        return
    }

    # Remove $1 if it's already in the path to prevent duplicates
    PATH="${PATH//:$1/}"
    PATH="${PATH//:$1:/}"
    PATH="${PATH//$1:/}"

    export PATH="${PATH:+"$PATH:"}$1"
}

env_init_ellipsis() {
    # Changeable globals
    export ELLIPSIS_INIT
    export ELLIPSIS_HOME
    export ELLIPSIS_PATH
    export ELLIPSIS_USER
    export ELLIPSIS_PACKAGES

    # Mainly for other scripts, as Ellipsis will be called from the wrapper
    # function
    env_append_path "$ELLIPSIS_BIN"
}

env_init_pkg() {
    # A path should contain at least one '/', this prevents local dirs with the
    # same name as a package from messing with the test.
    if [ "${1#/}" != "$1" ] && [ -d "$1" ]; then
        PKG_PATH="$1"
        PKG_NAME="${PKG_PATH##*/}"
    else
        PKG_NAME="$1"
        PKG_PATH="$ELLIPSIS_PACKAGES/$PKG_NAME"
    fi

    # Check if the package exists/has an ellipsis.sh file
    if [ -f "$PKG_PATH/ellipsis.sh" ]; then
        # Check if the package has an init hook
        pkg_init="$(sed -n '/^pkg.init\(\)/,/^}/p' "$PKG_PATH/ellipsis.sh" | sed '1 s/\./_/')"
        if [ -n "$pkg_init" ]; then
            eval "$pkg_init"
            # Handle some edge cases by checking if the function is available
            if command -v 'pkg_init' >/dev/null 2>&1; then
                {
                    cd "$PKG_PATH" || {
                        env_api log.error "Ellipsis could not cd to $PKG_PATH"
                        return
                    }

                    # Init or log an error
                    if ! pkg_init; then
                        env_api log.error "Ellipsis could not initialize $PKG_NAME"
                    fi
                }
                unset -f pkg_init
            else
                env_api log.error "Could not source pkg.init function for package $PKG_NAME"
            fi
        fi
        unset pkg_init
    else
        # Check if package exists or just hasn't got an ellipsis.sh file
        if [ ! -d "$PKG_PATH" ]; then
            env_api log.error "Package $PKG_NAME not found"
        fi
    fi

    unset pkg
    unset PKG_NAME
    unset PKG_PATH
}

# Init Ellipsis and packages
# !! Attention: Does not allow paths with spaces !!
env_init() {
    # Init all packages if no package is given
    if [ $# -eq 0 ]; then
        packages="$(echo "$ELLIPSIS_PACKAGES"/*)"
        if [  "$packages" = "$ELLIPSIS_PACKAGES/*" ]; then
            packages='ellipsis'
        else
            packages="ellipsis $packages"
        fi

        # Reuse the only array we have ($@)
        eval "set -- $packages"
        unset packages
    fi

    cwd=$PWD
    for pkg in "$@"; do
        case $pkg in
            ellipsis|Ellipsis)
                env_init_ellipsis
                ;;
            *)
                env_init_pkg "$pkg"
                ;;
        esac
    done
    cd "$cwd" || {
        env_api log.error "Ellipsis could not cd to $cwd"
        return
    }

    unset cwd

    # Clean up env
    env_clean_up
}

# Keep the environment as clean as possible
env_clean_up() {
    # Unset functions
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
