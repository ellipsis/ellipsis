#!/usr/bin/env bats

load _helper
source "$ELLIPSIS_SRC/env.sh"

setup() {
    ELLIPSIS_TMP="/tmp/ellipsis-tmp"
    mkdir -p "$ELLIPSIS_TMP"
}

teardown() {
    rm -rf "$ELLIPSIS_TMP"
}

path_wrapper() {
    "$@"
    echo "$PATH" > "$ELLIPSIS_TMP/path"
}

@test "init.sh should run the ellipsis init system" {
    skip "No test implementation"
}

@test "env.sh should be POSIX compliant" {
    run sh -c ". $ELLIPSIS_SRC/env.sh"
    [ "$status" -eq 0 ]
}

@test "env_api should call an ellipsis api function" {
    skip "No test implementation"
}

@test "env_prepend_path should prepend a dir to the PATH" {
    # Doesn't add non existent dirs
    run path_wrapper env_prepend_path "/does_not_exist"
    [ "$status" -eq 0 ]
    [ "$(cat "$ELLIPSIS_TMP/path")" = "$PATH" ]

    # Adds dir to the front of the PATH
    run path_wrapper env_prepend_path "$ELLIPSIS_TMP"
    [ "$status" -eq 0 ]
    [ "$(cat "$ELLIPSIS_TMP/path")" = "$ELLIPSIS_TMP:$PATH" ]

    # Doesn't add duplicates
    run path_wrapper env_prepend_path "$ELLIPSIS_TMP"
    [ "$status" -eq 0 ]
    [ "$(cat "$ELLIPSIS_TMP/path")" = "$ELLIPSIS_TMP:$PATH" ]
}

@test "env_append_path should append a dir to the PATH" {
    initial_path="$PATH"

    # Doesn't add non existent dirs
    run path_wrapper env_append_path "/does_not_exist"
    [ "$status" -eq 0 ]
    [ "$(cat "$ELLIPSIS_TMP/path")" = "$PATH" ]

    # Adds dir to the back of the PATH
    run path_wrapper env_append_path "$ELLIPSIS_TMP"
    [ "$status" -eq 0 ]
    [ "$(cat "$ELLIPSIS_TMP/path")" = "$PATH:$ELLIPSIS_TMP" ]

    # Doesn't add duplicates
    run path_wrapper env_append_path "$ELLIPSIS_TMP"
    [ "$status" -eq 0 ]
    [ "$(cat "$ELLIPSIS_TMP/path")" = "$PATH:$ELLIPSIS_TMP" ]
}

@test "env_init_ellipsis should add Ellipsis vars to the ENV" {
    skip "No test implementation"
}

@test "env_init_ellipsis should add ellipsis/bin to the PATH" {
    skip "No test implementation"
}

@test "env_init should run package init hooks" {
    skip "No test implementation"
}

@test "env_clean should clean up the env" {
    skip "No test implementation"
}

@test "ellipsis wrapper function should intercept 'ellipsis init'" {
    skip "No test implementation"
}
