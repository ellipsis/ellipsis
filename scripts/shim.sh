#!/bin/sh
#
# Shim for installer ellipsis install (http://ellipsis.sh).

# Ensure dependencies are installed.
deps=(bash curl git)

for dep in ${deps[*]}; do
    hash $dep 2>/dev/null || { echo >&2 "ellipsis requires $dep to be installed."; exit 1; }
done

# Download full installer and execute with bash
curl -L http://ellipsis.sh/scripts/install.sh > ellipsis-install.sh
bash ellipsis-install.sh
