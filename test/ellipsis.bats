#!/usr/bin/env bats

load _helper
load ellipsis
load utils

setup() {
    mkdir ellipsis-tmp
    mkdir ellipsis-test-home
    touch ellipsis-tmp/backupfile.file
    touch ellipsis-tmp/linkfile.file
    ln -s backupfile.file ellipsis-tmp/.a-good-symlink
    ln -s nothing ellipsis-tmp/.a-bad-symlink
    export ELLIPSIS_HOME="ellipsis-test-home"
}

teardown() {
    rm -rf ellipsis-tmp
    rm -rf ellipsis-test-home
}

@test "ellipsis.backup should make a backup of a file that exists" {
    run ellipsis.backup ellipsis-tmp/backupfile.file
    [ $status -eq 0 ]
    [ -f ellipsis-tmp/backupfile.file.bak ]
}

@test "ellipsis.backup should not make a backup of a file that does not exist" {
    run ellipsis.backup ellipsis-tmp/doesnotexist.file
    [ $status -eq 0 ]
    [ ! -f ellipsis-tmp/doesnotexist.file.bak ]
}

@test "ellipsis.backup should not overwrite existing backups" {
    touch ellipsis-tmp/backupfile.file.bak
    run ellipsis.backup ellipsis-tmp/backupfile.file
    [ $status -eq 0 ]
    [ -f ellipsis-tmp/backupfile.file.bak ]
    [ -f ellipsis-tmp/backupfile.file.bak.1 ]
}

@test "ellipsis.backup move symlink if passed a valid symlink" {
    run ellipsis.backup ellipsis-tmp/.a-good-symlink
    [ $status -eq 0 ]
    [ ! -L ellipsis-tmp/.a-good-symlink ]
    [ -L ellipsis-tmp/.a-good-symlink.bak ]
}

@test "ellipsis.backup should remove symlink if passed an invalid symlink" {
    run ellipsis.backup ellipsis-tmp/.a-bad-symlink
    [ $status -eq 0 ]
    [ ! -L ellipsis-tmp/.a-bad-symlink ]
    [ ! -e ellipsis-tmp/.a-bad-symlink ]
}

@test "ellipsis.link_file should link a file into HOME" {
    run ellipsis.link_file ellipsis-tmp/linkfile.file
    [ $status -eq 0 ]
    [ -f $(readlink $ELLIPSIS_HOME/.linkfile.file) ]
    [ -f ellipsis-tmp/linkfile.file ]
    [[ "$output" == linking* ]]
}

@test "ellipsis.link_files should link all the files in folder into HOME" {
    run ellipsis.link_files ellipsis-tmp
    [ $status -eq 0 ]
    [ -f $(readlink $ELLIPSIS_HOME/.linkfile.file) ]
    [ -f ellipsis-tmp/linkfile.file ]
    [ -f $(readlink $ELLIPSIS_HOME/.backupfile.file) ]
    [ -f ellipsis-tmp/backupfile.file ]
    [[ "$output" == linking* ]]
}
