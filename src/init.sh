#!/usr/bin/env bash
#
# init.sh
# Setup initial globals and load function used to source other modules.

# These globals can be set by a user to use a custom ellipsis fork/set of packages/etc
ELLIPSIS_USER="${ELLIPSIS_USER:-$(git config github.user)}"
ELLIPSIS_REPO="${ELLIPSIS_REPO:-https://github.com/$ELLIPSIS_USER/ellipsis}"
ELLIPSIS_PATH=${ELLIPSIS_PATH:-$HOME/.ellipsis}

# Default package operation act upon is ellipsis.
# These are highly mutable.
PKG_PATH=${PKG_PATH:-$ELLIPSIS_PATH}
PKG_NAME=${PKG_NAME:-${PKG_PATH##*/.}}

# Determine where we are
ELLIPSIS_SRC="${ELLIPSIS_SRC:-$(dirname "${BASH_SOURCE[0]}")}"

# Source other src files easily, and only once!
load() {
    source $ELLIPSIS_SRC/$1.sh
}

# Load version info.
load version

# Set flag that we've been sourced already.
ELLIPSIS_INIT=1
