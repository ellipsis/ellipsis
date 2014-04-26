#!/usr/bin/env bash
#
# init.sh
# Setup initial globals and load function used to source other modules.

# These globals can be set by a user to use a custom ellipsis fork/set of packages/etc

# git config returns 1 if key isn't found, so we pipe to cat to squash that in
# the case it's not-defined.
if [[ -z "$ELLIPSIS_USER" ]]; then
    GITHUB_USER=$(git config github.user | cat)
    ELLIPSIS_USER=${GITHUB_USER:-zeekay}
fi
ELLIPSIS_REPO=${ELLIPSIS_REPO:-https://github.com/$ELLIPSIS_USER/ellipsis}
ELLIPSIS_PATH="${ELLIPSIS_PATH:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Default package operation act upon is ellipsis.
# These are highly mutable.
PKG_PATH=${PKG_PATH:-$ELLIPSIS_PATH}
PKG_NAME=${PKG_NAME:-${PKG_PATH##*/.}}

# Source other src files easily, and only once!
load() {
    source $ELLIPSIS_PATH/src/$1.sh
}

# Load version info.
load version

# Set flag that we've been sourced already.
ELLIPSIS_INIT=1
