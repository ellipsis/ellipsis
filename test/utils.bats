#!/usr/bin/env bats

load _helper
load ellipsis
load utils

setup() {
    mkdir -p tmp/empty
    mkdir -p tmp/not_empty
    mkdir -p tmp/symlinks
    echo test > tmp/not_empty/file
    ln -s ../not_empty/file tmp/symlinks/symlink
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

@test "utils.list_symlinks should find symlinks in folder" {
    run utils.list_symlinks tmp/symlinks
    echo $output > out.txt
    [ "$output" = "tmp/symlinks/symlink" ]
}

@test "utils.list_symlinks should not find symlinks in folder without them" {
    run utils.list_symlinks tmp/empty
    [ "$output" = "" ]
    run utils.list_symlinks tmp/not_empty
    [ "$output" = "" ]
}

@test "utils.relative_path should print relative path to file" {
    run utils.relative_path $HOME/.ellipsis
    [ "$output" = "~/.ellipsis" ]
    run utils.relative_path ~/.ellipsis
    [ "$output" = "~/.ellipsis" ]
    run utils.relative_path tmp
    [ "$output" = "tmp" ]
}

@test "utils.prompt should return true if yes otherwise no" {
    skip
    run echo y | utils.prompt "select yes"
    [ status -eq 0 ]
}

@test "utils.prompt should return true if yes otherwise no" {
    skip
    run echo n | utils.prompt "select yes"
    [ status -eq 1 ]
}
