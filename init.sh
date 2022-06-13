#!/usr/bin/env sh

ELLIPSIS_INIT=1

# Set path variables
ELLIPSIS_PATH="${ELLIPSIS_PATH:-$HOME/.ellipsis}"
ELLIPSIS_BIN="$ELLIPSIS_PATH/bin"
ELLIPSIS_SRC="$ELLIPSIS_PATH/src"

# Default locations for ellipsis and packages.
ELLIPSIS_HOME="${ELLIPSIS_HOME:-$HOME}"
ELLIPSIS_PACKAGES="${ELLIPSIS_PACKAGES:-$ELLIPSIS_PATH/packages}"

if [ -z "$ELLIPSIS_USER" ]; then
    # Pipe to cat to squash git config's exit code 1 in case of missing key.
    GITHUB_USER="$(git config github.user | cat)"
    ELLIPSIS_USER="${GITHUB_USER:-${USERNAME:-$(whoami)}}"
fi

. "$ELLIPSIS_SRC/env.sh"

env_init "$@"
