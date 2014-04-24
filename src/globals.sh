#!/usr/bin/env bash
#
# globals.sh
# Globals used across various bits of Ellipsis.

# These globals can be set by a user to use a custom ellipsis fork/set of packages/etc
ELLIPSIS_USER="${ELLIPSIS_USER:-$(git config github.user)}"
ELLIPSIS_REPO="${ELLIPSIS_REPO:-https://github.com/$ELLIPSIS_USER/ellipsis}"
ELLIPSIS_PATH=${ELLIPSIS_PATH:-$HOME/.ellipsis}

# Default package operation act upon is ellipsis.
# These are highly mutable.
PKG_PATH=${PKG_PATH:-$ELLIPSIS_PATH}
PKG_NAME=${PKG_NAME:-${PKG_PATH##*/.}}

# Source version from version.sh, this makes it easy to update version.
source $(dirname "${BASH_SOURCE[0]}")/version.sh

# Set flag that we've been sourced already.
ELLIPSIS_GLOBALS=1
