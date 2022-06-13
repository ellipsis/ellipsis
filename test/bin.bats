#!/usr/bin/env bats
#
# Checks if bin/ellipsis does all it needs to do.

load _helper

setup() {
    mkdir -p "$TESTS_DIR/tmp"
    ln -s "$ELLIPSIS_PATH/bin/ellipsis" "$TESTS_DIR/tmp/l1"
    ln -s "$TESTS_DIR/tmp/l1" "$TESTS_DIR/tmp/l2"
    ln -s "$TESTS_DIR/tmp/l2" "$TESTS_DIR/tmp/l3"
    ln -s "$TESTS_DIR/tmp/l3" "$TESTS_DIR/tmp/l4"
    ln -s "$TESTS_DIR/tmp/l4" "$TESTS_DIR/tmp/ellipsis"
}

teardown() {
    rm -rf "$TESTS_DIR/tmp"
}

@test "ensure ellipsis is in real git repository" {
    # Ensure we are not in a worktree
    [ ! -f "$ELLIPSIS_PATH/.git" ]
    [ -d "$ELLIPSIS_PATH/.git" ]
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
