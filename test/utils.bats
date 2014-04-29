#!/usr/bin/env bats

load _helper
load utils

setup() {
    mkdir -p tmp/ellipsis_home
    export ELLIPSIS_HOME=tmp/ellipsis_home
}

teardown() {
    rm -rf $ELLIPSIS_HOME
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
