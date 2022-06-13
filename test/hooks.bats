#!/usr/bin/env bats

load _helper
load hooks

setup() {
    mkdir -p tmp/ellipsis_home
    export ELLIPSIS_HOME=tmp/ellipsis_home
}

teardown() {
    rm -rf tmp
}

@test "hooks.init should exist" {
    run hooks.init
    [ "$status" -eq 0 ]
}

@test "hooks.add" {
    skip "No test implementation"
    [ "$status" -eq 0 ]
}

@test "hooks.remove" {
    skip "No test implementation"
    [ "$status" -eq 0 ]
}

@test "hooks.install should exist" {
    run hooks.install
    [ "$status" -eq 0 ]
}

@test "hooks.installed" {
    skip "No test implementation"
    [ "$status" -eq 0 ]
}

@test "hooks.link" {
    skip "No test implementation"
    [ "$status" -eq 0 ]
}

@test "hooks.links" {
    skip "No test implementation"
    [ "$status" -eq 0 ]
}

@test "hooks.pull" {
    skip "No test implementation"
    [ "$status" -eq 0 ]
}

@test "hooks.push" {
    skip "No test implementation"
    [ "$status" -eq 0 ]
}

@test "hooks.status" {
    skip "No test implementation"
    [ "$status" -eq 0 ]
}

@test "hooks.uninstall" {
    skip "No test implementation"
    [ "$status" -eq 0 ]
}

@test "hooks.unlink" {
    skip "No test implementation"
    [ "$status" -eq 0 ]
}
