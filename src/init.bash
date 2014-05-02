# init.bash
#
# Setup initial globals and load function used to source other modules. This
# file must be sourced before any others.

if [[ -z "$ELLIPSIS_USER" ]]; then
    # Pipe to cat to squash git config's exit code 1 in case of missing key.
    GITHUB_USER=$(git config github.user | cat)
    ELLIPSIS_USER=${GITHUB_USER:-zeekay}
fi

# Repostitory defaults.
ELLIPSIS_PROTO="${ELLIPSIS_PROTO:-https}"
ELLIPSIS_REPO="${ELLIPSIS_REPO:-https://github.com/$ELLIPSIS_USER/ellipsis}"

# Default locations for ellipsis and packages.
ELLIPSIS_HOME="${ELLIPSIS_HOME:-$HOME}"
ELLIPSIS_PATH="${ELLIPSIS_PATH:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
ELLIPSIS_PACKAGES="${ELLIPSIS_PACKAGES:-$ELLIPSIS_PATH/packages}"

# Ellipsis is the default package.
PKG_PATH=${PKG_PATH:-$ELLIPSIS_PATH}
PKG_NAME=${PKG_NAME:-${PKG_PATH##*/.}}

# Utility to load other modules. Uses a tiny bit of black magic to ensure each
# module is only loaded once.
load() {
    # Use indirect expansion to reference dynamic variable which flags this
    # module as loaded.
    local loaded="__loaded_$1"

    # Only source modules once
    if [[ -z "${!loaded}" ]]; then
        # Mark this module as loaded, prevent infinite recursion, ya know...
        eval "$loaded=1"

        source $ELLIPSIS_PATH/src/$1.bash
    fi
}

# Load version info.
load version

# Set flag that we've been sourced already.
ELLIPSIS_INIT=1
