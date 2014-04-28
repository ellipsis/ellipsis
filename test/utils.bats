#!/usr/bin/env bats

load _helper
load ellipsis
load utils

setup() {
    mkdir -p tmp/empty
    mkdir -p tmp/not_empty
    mkdir -p tmp/symlinks
    echo test > tmp/not_empty/file
    ln -s ../not_empty/file tmp/symlinks/symlink
    ln -s does_not_exist tmp/symlinks/brokensymlink
}

teardown() {
    rm -rf tmp
}

@test "utils.cmd_exists should find command in PATH" {
    run utils.cmd_exists bats
    [ $status -eq 0 ]
}

@test "utils.cmd_exists should not find commands not in PATH" {
    run utils.cmd_exists gobbledygook
    [ $status -eq 1 ]
}

@test "utils.prompt should return true if yes otherwise no" {
    skip
    run echo y | utils.prompt "select yes"
    [ status -eq 0 ]
}

@test "utils.prompt should return true if yes otherwise no" {
    skip
    run echo n | utils.prompt "select yes"
    [ status -eq 1 ]
}
