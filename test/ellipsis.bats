#!/usr/bin/env bats

load _helper
load ellipsis
load utils

setup() {
    mkdir -p tmp/ellipsis_home
    touch tmp/file_to_backup
    touch tmp/file_to_link
    ln -s file_to_backup tmp/symlink
    ln -s nothing tmp/broken_symlink
    export ELLIPSIS_HOME=tmp/ellipsis_home
}

teardown() {
    rm -rf tmp
    rm -rf $ELLIPSIS_HOME
}

@test "ellipsis.backup should make a backup of a file that exists" {
    run ellipsis.backup tmp/file_to_backup
    [ $status -eq 0 ]
    [ -f tmp/file_to_backup.bak ]
}

@test "ellipsis.backup should not make a backup of a file that does not exist" {
    run ellipsis.backup tmp/doesnotexist.file
    [ $status -eq 0 ]
    [ ! -f tmp/doesnotexist.file.bak ]
}

@test "ellipsis.backup should not overwrite existing backups" {
    touch tmp/file_to_backup.bak
    run ellipsis.backup tmp/file_to_backup
    [ $status -eq 0 ]
    [ -f tmp/file_to_backup.bak ]
    [ -f tmp/file_to_backup.bak.1 ]
}

@test "ellipsis.backup move symlink if passed a valid symlink" {
    run ellipsis.backup tmp/symlink
    [ $status -eq 0 ]
    [ ! -L tmp/symlink ]
    [ -L tmp/symlink.bak ]
}

@test "ellipsis.backup should remove symlink if passed an invalid symlink" {
    run ellipsis.backup tmp/broken_symlink
    [ $status -eq 0 ]
    [ ! -L tmp/broken_symlink ]
    [ ! -e tmp/broken_symlink ]
}

@test "ellipsis.link_file should link a file into HOME" {
    run ellipsis.link_file tmp/file_to_link
    [ $status -eq 0 ]
    [ -f $(readlink $ELLIPSIS_HOME/.file_to_link) ]
    [ -f tmp/file_to_link ]
    [[ "$output" == linking* ]]
}

@test "ellipsis.link_files should link all the files in folder into HOME" {
    run ellipsis.link_files tmp
    [ $status -eq 0 ]
    [ -f $(readlink $ELLIPSIS_HOME/.file_to_link) ]
    [ -f tmp/file_to_link ]
    [ -f $(readlink $ELLIPSIS_HOME/.file_to_backup) ]
    [ -f tmp/file_to_backup ]
    [[ "$output" == linking* ]]
}
