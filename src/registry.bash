# registry.bash
#
# Interface to ellipsis package manager index. Uses github under the covers.

load github

# Search registry for ellipsis packages.
registry.search() {
    github.search $1 | github.format_json
}

# List ellipsis packages in registry.
registry.available() {
    github.list_repos | github.format_json
}

# Publish packge to repository.
registry.publish() {
    echo TODO
}
