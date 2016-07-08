#!/usr/bin/env bats

load _helper

@test "vars.sh should be POSIX compliant when sourced" {
    # Check with bash compatibility mode
    run bash --posix -c "source $ELLIPSIS_SRC/vars.bash"
    [ "$status" -eq 0 ]

    # Also check for double square brackets
    run grep -E '\[\[|\]\]' "$ELLIPSIS_SRC/vars.bash"
    [ "$status" -ne 0 ]
}
