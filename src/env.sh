# env.sh [POSIX]
#
# Functions to manage the env

# PATH helper, if exists, prepend, no duplication
env.prepend_path() {
    local duplicates="$(grep -c "(^|:)$1(:|$)" <<< "$PATH")"
    if [ -d "$1" ] && [ "$duplicates" -eq 0 ]; then
        export PATH="$1:$PATH"
    fi
}

# PATH helper, if exists, append, no duplication
env.append_path() {
    local duplicates="$(grep -c "(^|:)$1(:|$)" <<< "$PATH")"
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
    # @TODO: reenable when fixed
    #env.append_path "$ELLIPSIS_BIN"
}

env.init() {
    local packages="$@"

    # Init all packages if no package is given
    if [ "$#" -eq 0 ]; then
        packages="ellipsis $(echo "$ELLIPSIS_PACKAGES/*")"
    fi

    for pkg in $packages; do
        if [ "$pkg" = "Ellipsis" -o "$pkg" = "ellipsis" ]; then
            env.init_ellipsis
        else
            #pkg.env_up "$pkg"
            #pkg.run_hook "init"
            #pkg.env_down
            echo "$pkg could not be initialized"
        fi
    done

    # Clean up env
    unset env.init_ellipsis
    unset env.init
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
