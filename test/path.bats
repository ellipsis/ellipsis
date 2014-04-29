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

@test "path.pkg_name_from_path should derive package name from package path" {
    skip
}

@test "path.pkg_path_from_name should derive package path from package name" {
    skip
}

@test "path.relative_path should print relative path to file" {
    run path.relative_path $HOME/.ellipsis
    [ "$output" = "~/.ellipsis" ]
    run path.relative_path ~/.ellipsis
    [ "$output" = "~/.ellipsis" ]
    run path.relative_path tmp
    [ "$output" = "tmp" ]
}
