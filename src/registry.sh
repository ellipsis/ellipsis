#!/usr/bin/env bash
#
# registry.sh
# Interface to ellipsis package manager index. Uses github under the covers.

# Initialize ourselves if we haven't yet.
if [[ $ELLIPSIS_INIT -ne 1 ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")"/init.sh
fi

# Load deps.
load github

# Search registry for ellipsis packages.
registry.search_packages() {
    github.search $1 | github.format_json
}

# List ellipsis packages in registry.
registry.list_packages() {
    github.list_repos | github.format_json
}
