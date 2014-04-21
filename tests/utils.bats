#!/usr/bin/env bats

load _helper
load ../src/utils

@test "utils.cmd_exists should be able to tell if a command is in PATH" {
  utils.cmd_exists bats
}

@test "utils.cmd_exists should return 1 if executable not in PATH" {
  ! utils.cmd_exists gobbledygook
}
