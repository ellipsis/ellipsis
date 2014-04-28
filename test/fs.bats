#!/usr/bin/env bats

load _helper
load ellipsis
load fs

setup() {
    mkdir -p tmp/empty
    mkdir -p tmp/not_empty
    mkdir -p tmp/symlinks
    echo test > tmp/not_empty/file
    ln -s ../not_empty/file tmp/symlinks/symlink
    ln -s does_not_exist tmp/symlinks/brokensymlink
}

teardown() {
    rm -rf tmp
}

@test "fs.file_exists should detect file that exists" {
    run fs.file_exists tmp/not_empty
    [ $status -eq 0 ]
    run fs.file_exists tmp/not_empty/file
    [ $status -eq 0 ]
}

@test "fs.file_exists should not detect files that don't exist" {
    run fs.file_exists does_not_exist
    [ $status -eq 1 ]
}

@test "fs.folder_empty should detect an empty folder" {
    run fs.folder_empty tmp/empty
    [ $status -eq 0 ]
}

@test "fs.folder_empty should not detect non-empty folder" {
    run fs.folder_empty tmp/not_empty
    [ $status -eq 1 ]
}

@test "fs.is_symlink should identify symlink" {
    run fs.is_symlink tmp/symlinks/symlink
    [ $status -eq 0 ]
    run fs.is_symlink tmp/symlinks/brokensymlink
    [ $status -eq 0 ]
    run fs.is_symlink tmp/not_empty
    [ $status -eq 1 ]
    run fs.is_symlink tmp/not_empty/file
    [ $status -eq 1 ]
}

@test "fs.is_broken_symlink should identify broken symlink" {
    run fs.is_broken_symlink tmp/symlinks/brokensymlink
    [ $status -eq 0 ]
    run fs.is_broken_symlink tmp/symlinks/symlink
    [ $status -eq 1 ]
    run fs.is_broken_symlink tmp/not_empty
    [ $status -eq 1 ]
    run fs.is_broken_symlink tmp/not_empty/file
    [ $status -eq 1 ]
}

@test "fs.list_symlinks should not find symlinks in folder without them" {
    run fs.list_symlinks tmp/empty
    [ "$output" = "" ]
    run fs.list_symlinks tmp/not_empty
    [ "$output" = "" ]
}

@test "fs.relative_path should print relative path to file" {
    run fs.relative_path $HOME/.ellipsis
    [ "$output" = "~/.ellipsis" ]
    run fs.relative_path ~/.ellipsis
    [ "$output" = "~/.ellipsis" ]
    run fs.relative_path tmp
    [ "$output" = "tmp" ]
}
