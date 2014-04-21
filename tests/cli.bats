#!/usr/bin/env bats

@test "invoking ellipsis without arguments prints usage" {
  run ellipsis
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "Usage: ellipsis <command>" ]
}

@test "invoking ellipsis with gobbledygook arguments prints usage" {
  run ellipsis gobbledygook
  [ "$status" -eq 1 ]
  [ "${lines[1]}" = "Usage: ellipsis <command>" ]
}
