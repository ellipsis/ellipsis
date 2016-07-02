# init.bash
#
# Setup initial globals and load function used to source other modules. This
# file must be sourced before any others.

# Count nested runs for msg indentation
if [ -z "$ELLIPSIS_LVL" ]; then
    export ELLIPSIS_LVL=1
else
    let ELLIPSIS_LVL=ELLIPSIS_LVL+1
fi

if [ -z "$ELLIPSIS_USER" ]; then
    # Pipe to cat to squash git config's exit code 1 in case of missing key.
    GITHUB_USER="$(git config github.user | cat)"
    ELLIPSIS_USER="${GITHUB_USER:-${USERNAME:-$(whoami)}}"
fi

# Repostitory defaults.
ELLIPSIS_PROTO="${ELLIPSIS_PROTO:-https}"
ELLIPSIS_REPO="${ELLIPSIS_REPO:-https://github.com/$ELLIPSIS_USER/ellipsis}"

# Default locations for ellipsis and packages.
ELLIPSIS_HOME="${ELLIPSIS_HOME:-$HOME}"
ELLIPSIS_PACKAGES="${ELLIPSIS_PACKAGES:-$ELLIPSIS_PATH/packages}"

# Ellipsis is the default package.
PKG_PATH="${PKG_PATH:-$ELLIPSIS_PATH}"
PKG_NAME="${PKG_NAME:-${PKG_PATH##*/.}}"

# Utility to load other modules. Uses a tiny bit of black magic to ensure each
# module is only loaded once.
load() {
    # Set dynamic loaded variable name
    local loaded="__loaded_$1"

    # Get status of loaded variable
    eval "local status=\"\$$loaded\""

    # Only source modules once
    if [ -z "$status" ]; then
        # Mark this module as loaded, prevent infinite recursion, ya know...
        eval "$loaded=1"

        # Load extension specific sources if possible
        if [ -n "$ELLIPSIS_XSRC" -a -f "$ELLIPSIS_XSRC/$1.bash" ]; then
            source "$ELLIPSIS_XSRC/$1.bash"
        else
            source "$ELLIPSIS_SRC/$1.bash"
        fi
    fi
}

# Load version info.
load version
