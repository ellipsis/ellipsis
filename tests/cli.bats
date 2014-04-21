#!/usr/bin/env bats

load _helper

@test "cli.run without command prints usage" {
  run ellipsis
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "Usage: ellipsis <command>" ]
}

@test "cli.run with invalid command prints usage" {
  run ellipsis invalid_command
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
  # [ $(expr "$output" : "v[0-9][0-9.]*") -ne 0 ]
}
