#!/usr/bin/env bats

load _helper
load msg

@test "msg.print shows message" {
    ELLIPSIS_FORCE_COLOR=1\
    run msg.print "\033[1mTest print message\033[0m"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "[1mTest print message[0m" ]
}

@test "msg.print shows message colorless (non interactive)" {
    run msg.print "\033[1mTest print message (colored)\033[0m"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Test print message (colored)" ]
}

@test "msg.log shows message without colors" {
    run msg.log "\033[1mTest no color message\033[0m"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Test no color message" ]
}

@test "msg.bold shows bold message" {
    ELLIPSIS_FORCE_COLOR=1\
    run msg.bold "Test bold message"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "[1mTest bold message[0m" ]
}

@test "msg.bold shows bold message colorless (non interactive)" {
    run msg.bold "Test bold message"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Test bold message" ]
}

@test "msg.dim shows dim message" {
    ELLIPSIS_FORCE_COLOR=1\
    run msg.dim "Test dim message"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "[90mTest dim message[0m" ]
}

@test "msg.dim shows dim message colorless (non interactive)" {
    run msg.dim "Test dim message"
    [ "$status" -eq 0 ]
    [ "${lines[0]}" = "Test dim message" ]
}
