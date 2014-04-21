#!/usr/bin/env bats

load _helper
load utils

setup() {
    mkdir -p tmp/empty
    mkdir -p tmp/not_empty
    touch tmp/not_empty/file
}

teardown() {
    rm -rf tmp
}

@test "utils.cmd_exists should find command in PATH" {
  run utils.cmd_exists bats
  [ $status -eq 0 ]
}

@test "utils.cmd_exists should not find commands not in PATH" {
  run utils.cmd_exists gobbledygook
  [ $status -eq 1 ]
}

@test "utils.folder_empty should detect an empty folder" {
  run utils.folder_empty tmp/empty
  [ $status -eq 0 ]
}

@test "utils.folder_empty should not detect non-empty folder" {
  run utils.folder_empty tmp/not_empty
  [ $status -eq 1 ]
}
