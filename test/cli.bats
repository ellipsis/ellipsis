#!/usr/bin/env bats

load _helper
load cli

@test "cli.usage shows usage info" {
  skip "No test implementation"
  run cli.usage
  [ "$status" -eq 0 ]
}

@test "cli.version prints version" {
  skip "No test implementation"
  run cli.version
  [ "$status" -eq 0 ]
}

@test "cli.info shows ellipsis info" {
  skip "No test implementation"
  run cli.info
  [ "$status" -eq 0 ]
}

@test "cli.load_config sources first found config file" {
  skip "No test implementation"
  run cli.load_config
  [ "$status" -eq 0 ]
}

@test "cli.run without command prints usage" {
  run cli.run
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = "Usage: ellipsis <command>" ]
}

@test "cli.run with invalid command prints usage" {
  run cli.run invalid_command
  [ "$status" -eq 1 ]
  [ "${lines[1]}" = "Usage: ellipsis <command>" ]
}

@test "cli.run --help prints usage" {
  run cli.run --help
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Usage: ellipsis <command>" ]
}

@test "cli.run --version prints version" {
  run cli.run --version
  [ "$status" -eq 0 ]
  [ $(expr "$output" : "v[0-9][0-9.]*") -ne 0 ]
}
