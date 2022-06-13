#!/usr/bin/env bats

load _helper
load cli

teardown() {
    rm -rf tmp
}

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
    # Setup
    mkdir -p tmp/source_files
    echo "TEST_VAR=file2" > tmp/source_files/file2
    echo "TEST_VAR=file3" > tmp/source_files/file3
    test_cli_load_config() {
        export HOME='/does-not-exist'
        export XDG_CONFIG_HOME=''
        cli.load_config
        echo "$ELLIPSIS_CCONFIG"
        echo "$TEST_VAR"
    }

    # Test successful
    ELLIPSIS_CONFIG='tmp/source_files/file2' run test_cli_load_config
    [ $status -eq 0 ]
    [ "${lines[0]}" == "${PWD}/tmp/source_files/file2" ]
    [ "${lines[1]}" == "file2" ]

    # Test failing source
    ELLIPSIS_CONFIG='tmp/source_files/file1' run test_cli_load_config
    [ $status -eq 0 ]
    [ "$output" = "" ]
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
