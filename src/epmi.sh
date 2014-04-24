#!/usr/bin/env bash
#
# epmi.sh
# Interface to ellipsis package manager index. Uses github under the covers.

# Initialize ourselves if we haven't yet.
if [[ $ELLIPSIS_INIT -ne 1 ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")"/init.sh
fi

# Search epmi org for ellipsis packages.
epmi.search_packages() {
    github.search $1 | gitub.format_json
}

# Lis epmi org ellipsis packages.
epmi.list_packages() {
    github.list_repos | gitub.format_json
}
