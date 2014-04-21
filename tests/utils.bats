#!/usr/bin/env bats

source $HOME/.ellipsis/src/utils.sh

@test "utils.cmd_exists should be able to tell if a command is in $PATH" {
  utils.cmd_exists bats
  [ "$status" -eq 0 ]
}

@test "utils.cmd_exists should return 1 if executable not in $PATH" {
  utils.cmd_exists gobbledygook
  [ "$status" -eq 1 ]
}
