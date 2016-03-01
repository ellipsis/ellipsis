#!/usr/bin/env bats

load _helper
load extension

@test "extension.is_compatible checks compatibility" {
    run extension.is_compatible "$ELLIPSIS_VERSION"
    [ $status -eq 0 ]
    run extension.is_compatible "0.0.1"
    [ $status -eq 0 ]
    run extension.is_compatible "999.0.0"
    [ $status -eq 1 ]
}

