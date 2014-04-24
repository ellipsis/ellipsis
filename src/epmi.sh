#!/usr/bin/env bash
#
# epmi.sh
# Interface to ellipsis package manager index. Uses github under the covers.

# Initialize ourselves if we haven't yet.
if [[ $ELLIPSIS_INIT -ne 1 ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")"/init.sh
fi

# Load deps.
load github

# Search epmi org for ellipsis packages.
epmi.search_packages() {
    github.search $1 | github.format_json
}

# Lis epmi org ellipsis packages.
epmi.list_packages() {
    github.list_repos | github.format_json
}
