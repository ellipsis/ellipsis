# vars.bash [POSIX]
#
# Global variables

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
