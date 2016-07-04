# env.sh [POSIX]
#
# Functions to manage the env

# Don't use ELLIPSIS_LVL
unset ELLIPSIS_LVL

env.api() {
    bash ellipsis api "$@"
}

# PATH helper, if exists, prepend, no duplication
env.prepend_path() {
    duplicates="$(grep -Ec "(^|:)$1(:|$)" <<< "$PATH")"
    if [ -d "$1" ] && [ "$duplicates" -eq 0 ]; then
        export PATH="$1:$PATH"
    fi
}

# PATH helper, if exists, append, no duplication
env.append_path() {
    duplicates="$(grep -Ec "(^|:)$1(:|$)" <<< "$PATH")"
    if [ -d "$1" ] && [ "$duplicates" -eq 0 ]; then
        export PATH="$PATH:$1"
    fi
}

env.init_ellipsis() {
    export ELLIPSIS_BIN
    export ELLIPSIS_SRC
    export ELLIPSIS_HOME
    export ELLIPSIS_PATH
    export ELLIPSIS_USER
    export ELLIPSIS_PACKAGES

    # Mainly for other scripts, as Ellipsis will be called from the wrapper
    # function
    env.append_path "$ELLIPSIS_BIN"
}

env.init() {
    packages="$@"

    # Init all packages if no package is given
    if [ "$#" -eq 0 ]; then
        packages="ellipsis $(env.api ellipsis.list_packages)"
    fi

    for pkg in $packages; do
        # @TODO: ? add some output if run interactively?

        if [ "$pkg" = "Ellipsis" -o "$pkg" = "ellipsis" ]; then
            env.init_ellipsis
        else
            if env.api path.is_path "$pkg"; then
                PKG_PATH="$pkg"
                PKG_NAME="$(env.api pkg.name_from_path "$PKG_PATH")"
            else
                PKG_NAME="$pkg"
                PKG_PATH="$(env.api pkg.path_from_name "$PKG_NAME")"
            fi

            # Check if package exists
            if [ -d "$PKG_PATH" -a -f "$PKG_PATH/ellipsis.sh" ]; then

                # Extract init function
                pkg_init="$(bash -c "source $PKG_PATH/ellipsis.sh; declare -f pkg.init")"
                eval "$pkg_init"

                if hash "pkg.init" &> /dev/null; then
                    cwd="$(pwd)"
                    cd "$PKG_PATH"

                    pkg.init

                    cd "$cwd"
                    unset -f pkg.init
                fi

                unset pkg_init
            fi

            unset PKG_PATH
            unset PKG_NAME
        fi
    done

    # Clean up env
    unset -f env.api
    unset -f env.init_ellipsis
    unset -f env.init
}

# Special wrapper function to catch init (env) commands. This wrapper makes it
# possible to call the init hooks from within the current shell
ellipsis() {
    case $1 in
        init)
            # Remove init from $@
            shift

            # Source ellipsis with current shell
            source "$ELLIPSIS_BIN/ellipsis"
            ;;
        *)
            # Run ellipsis with bash
            "$ELLIPSIS_BIN/ellipsis" "$@"
            ;;
    esac
}
