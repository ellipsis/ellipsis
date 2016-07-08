#!/usr/bin/env bats
#
# Checks if bin/ellipsis does all it needs to do.

setup() {
    export TESTS_DIR="$BATS_TEST_DIRNAME"
    export _ELLIPSIS_PATH="$(cd "$TESTS_DIR/.." && pwd)"
    export PATH="$_ELLIPSIS_PATH/bin:$PATH"
    mkdir -p "$TESTS_DIR/tmp"
    ln -s "$_ELLIPSIS_PATH/bin/ellipsis" "$TESTS_DIR/tmp/l1"
    ln -s "$TESTS_DIR/tmp/l1" "$TESTS_DIR/tmp/l2"
    ln -s "$TESTS_DIR/tmp/l2" "$TESTS_DIR/tmp/l3"
    ln -s "$TESTS_DIR/tmp/l3" "$TESTS_DIR/tmp/l4"
    ln -s "$TESTS_DIR/tmp/l4" "$TESTS_DIR/tmp/ellipsis"
}

teardown() {
    rm -rf "$TESTS_DIR/tmp"
}

@test "ellipsis should be POSIX compliant when sourced" {
    # Check with bash compatibility mode
    run bash --posix -c "source $ELLIPSIS_PATH/bin/ellipsis"
    [ "$status" -eq 0 ]

    # Also check for double square brackets
    run grep -E '\[\[|\]\]' "$ELLIPSIS_PATH/bin/ellipsis"
    [ "$status" -ne 0 ]
}

@test "ellipsis should call env_init when sourced" {
    skip "No test implementation"
}

@test "ellipsis <command> calls cli.run <command>" {
    run ellipsis version
    [ "$status" -eq 0 ]
    [ $(expr "$output" : "v[0-9][0-9.]*") -ne 0 ]
}

@test "ellipsis can find its location trough multiple symlinks" {
    run "$TESTS_DIR/tmp/ellipsis" version
    [ "$status" -eq 0 ]
}
