#!/usr/bin/env bats

@test "cli.run without arguments prints usage" {
  run ellipsis
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "Usage: ellipsis <command>" ]
}

@test "cli.run with invalid arguments prints usage" {
  run ellipsis gobbledygook
  [ "$status" -eq 1 ]
  [ "${lines[1]}" = "Usage: ellipsis <command>" ]
}

@test "cli.run --help prints usage" {
  run ellipsis --help
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Usage: ellipsis <command>" ]
}

@test "cli.run --version prints version" {
  run ellipsis --version
  [ "$status" -eq 0 ]
  [ $(expr "$output" : "v[0-9][0-9.]*") -ne 0 ]
}
