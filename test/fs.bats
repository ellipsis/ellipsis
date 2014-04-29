#!/usr/bin/env bats

load _helper
load fs

setup() {
    mkdir -p tmp/ellipsis_home/.ellipsis
    export ELLIPSIS_HOME=tmp/ellipsis_home
    export ELLIPSIS_PATH=$ELLIPSIS_HOME/.ellipsis
    touch tmp/file_to_backup
    touch tmp/file_to_link
    ln -s file_to_backup tmp/symlink
    ln -s nothing tmp/broken_symlink
    mkdir -p tmp/empty
    mkdir -p tmp/not_empty
    mkdir -p tmp/symlinks
    echo test > tmp/not_empty/file
    ln -s ../not_empty/file tmp/symlinks/symlink
    ln -s $ELLIPSIS_PATH/test $ELLIPSIS_HOME/.test
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

@test "fs.backup should make a backup of a file that exists" {
    run fs.backup tmp/file_to_backup
    [ $status -eq 0 ]
    [ -f tmp/file_to_backup.bak ]
}

@test "fs.backup should not make a backup of a file that does not exist" {
    run fs.backup tmp/doesnotexist.file
    [ $status -eq 0 ]
    [ ! -f tmp/doesnotexist.file.bak ]
}

@test "fs.backup should not overwrite existing backups" {
    touch tmp/file_to_backup.bak
    run fs.backup tmp/file_to_backup
    [ $status -eq 0 ]
    [ -f tmp/file_to_backup.bak ]
    [ -f tmp/file_to_backup.bak.1 ]
}

@test "fs.backup move symlink if passed a valid symlink" {
    run fs.backup tmp/symlink
    [ $status -eq 0 ]
    [ ! -L tmp/symlink ]
    [ -L tmp/symlink.bak ]
}

@test "fs.backup should remove symlink if passed an invalid symlink" {
    run fs.backup tmp/broken_symlink
    [ $status -eq 0 ]
    [ ! -L tmp/broken_symlink ]
    [ ! -e tmp/broken_symlink ]
}

@test "fs.link_file should link a file into HOME" {
    run fs.link_file tmp/file_to_link
    [ $status -eq 0 ]
    [ -f $(readlink $ELLIPSIS_HOME/.file_to_link) ]
    [ -f tmp/file_to_link ]
    [[ "$output" == linking* ]]
}

@test "fs.link_files should link all the files in folder into HOME" {
    run fs.link_files tmp
    [ $status -eq 0 ]
    [ -f $(readlink $ELLIPSIS_HOME/.file_to_link) ]
    [ -f tmp/file_to_link ]
    [ -f $(readlink $ELLIPSIS_HOME/.file_to_backup) ]
    [ -f tmp/file_to_backup ]
    [[ "$output" == linking* ]]
}

@test "fs.is_ellipsis_symlink should detect symlink pointing back to ELLIPSIS_PATH" {
    run fs.is_ellipsis_symlink $ELLIPSIS_HOME/.test
    [ $status -eq 0 ]
}
