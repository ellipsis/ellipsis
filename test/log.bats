#!/usr/bin/env bats

load _helper
load log

setup() {
    mkdir -p tmp
    export ELLIPSIS_LOGFILE=tmp/log
}

teardown() {
    rm -rf tmp
}

in_log() {
    local msg="$1"
    local regex="([0-9]{1,2}/){2}[0-9]{1,2} ([0-9]{1,2}:){3} $msg"

    grep -E "$regex" "$ELLIPSIS_LOGFILE" >/dev/null 2>&1
    echo "$?"
}

@test "log.store stores messages to logfile" {
    run log.store "err_type" "Test file logging"
    [ "$status" -eq 0 ]
    [ "$output" = "err_type Test file logging" ]
    [ "$(in_log "err_type Test file logging")" -eq 0 ]
}

@test "log.store stores messages colorless" {
    ELLIPSIS_FORCE_COLOR=1\
    run log.store "\033[32m ok \033[0m" "Test file logging"
    [ "$status" -eq 0 ]
    [ "$output" = "[32m ok [0m Test file logging" ]
    [ "$(in_log " ok  Test file logging")" -eq 0 ]
}

@test "log.store stores messages with extension prefix when needed" {
    ELLIPSIS_XNAME="Test"\
    run log.store "err_type" "Test file logging"
    [ "$status" -eq 0 ]
    [ "$output" = "err_type Test file logging" ]
    [ "$(in_log "err_type Test : Test file logging")" -eq 0 ]
}

@test "log.ok logs success" {
    ELLIPSIS_FORCE_COLOR=1\
    run log.ok "Test success message"
    [ "$status" -eq 0 ]
    [ "$output" = "[[32m ok [0m] Test success message" ]
}

@test "log.ok logs success colorless (non interactive)" {
    run log.ok "Test success message"
    [ "$status" -eq 0 ]
    [ "$output" = "[ ok ] Test success message" ]
}

@test "log.info logs info" {
    ELLIPSIS_FORCE_COLOR=1\
    run log.info "Test info message"
    [ "$status" -eq 0 ]
    [ "$output" = "[[36minfo[0m] Test info message" ]
}

@test "log.info logs info colorless (non interactive)" {
    run log.info "Test info message"
    [ "$status" -eq 0 ]
    [ "$output" = "[info] Test info message" ]
}

@test "log.warn logs warning" {
    ELLIPSIS_FORCE_COLOR=1\
    run log.warn "Test warning message"
    [ "$status" -eq 0 ]
    [ "$output" = "[[33mwarn[0m] Test warning message" ]
}

@test "log.warn logs warning colorless (non interactive)" {
    run log.warn "Test warning message"
    [ "$status" -eq 0 ]
    [ "$output" = "[warn] Test warning message" ]
}

@test "log.error logs error" {
    ELLIPSIS_FORCE_COLOR=1\
    run log.error "Test error message"
    [ "$status" -eq 0 ]
    [ "$output" = "[[31m err[0m] Test error message" ]
}

@test "log.error logs error colorless (non interactive)" {
    run log.error "Test error message"
    [ "$status" -eq 0 ]
    [ "$output" = "[ err] Test error message" ]
}

@test "log.fail logs failure" {
    ELLIPSIS_FORCE_COLOR=1\
    run log.fail "Test fail message"
    [ "$status" -eq 0 ]
    [ "$output" = "[[31mFAIL[0m] Test fail message" ]
}

@test "log.fail logs failure colorless (non interactive)" {
    run log.fail "Test fail message"
    [ "$status" -eq 0 ]
    [ "$output" = "[FAIL] Test fail message" ]
}

@test "log.dim shows dimmed message" {
    ELLIPSIS_FORCE_COLOR=1\
    run log.dim "Test dim message"
    [ "$status" -eq 0 ]
    [ "$output" = "[90mTest dim message[0m" ]
}

@test "log.dim shows dimmed message colorless (non interactive)" {
    run log.dim "Test dim message"
    [ "$status" -eq 0 ]
    [ "$output" = "Test dim message" ]
}
