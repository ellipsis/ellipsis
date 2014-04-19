#!/bin/sh
#
# Installer for ellipsis (http://ellipsis.sh)

ELLIPSIS_USER="${ELLIPSIS_USER:-zeekay}"
ELLIPSIS_REPO="${ELLIPSIS_REPO:-https://github.com/$ELLIPSIS_USER/ellipsis}"
ELLIPSIS_URL="${ELLIPSIS_URL:-https://raw.githubusercontent.com/$ELLIPSIS_USER/ellipsis/master}"

# Ensure dependencies are installed.
deps=(bash curl git)

for dep in deps; do
    hash $dep 2>/dev/null || { echo >&2 "ellipsis requires $dep to be installed."; exit 1; }
done

# Create temp directory
dir=$(mktemp -d)
cd $dir

# Download lib components
curl -s "$ELLIPSIS_URL/src/git.sh" > git.sh
curl -s "$ELLIPSIS_URL/src/ellipsis.sh" > ellipsis.sh

# Switch to bash
bash

# source lib files
source git.sh
source ellipsis.sh

ellipsis.backup ~/.ellipsis

# Download latest copy of ellipsis
git.clone "$ELLIPSIS_REPO" ~/.ellipsis

trap "exit 0" SIGINT

if [ -z "$ELLIPSIS_MODULES" ]; then
    ellipsis.list
    read modules </dev/tty
else
    modules="$ELLIPSIS_MODULES"
fi

for module in $modules; do
    echo
    ellipsis.install $module
done
