#!/usr/bin/env bats

load _helper
load path

setup() {
    mkdir -p tmp/ellipsis_home
    export ELLIPSIS_HOME=tmp/ellipsis_home
}

teardown() {
    rm -rf $ELLIPSIS_HOME
}

@test "path.relative_to_home should print path relative to $HOME" {
    run path.relative_to_home $HOME/.ellipsis
    [ "$output" = "~/.ellipsis" ]
    run path.relative_to_home ~/.ellipsis
    [ "$output" = "~/.ellipsis" ]
    run path.relative_to_home tmp
    [ "$output" = "tmp" ]
}
