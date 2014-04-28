#!/usr/bin/env bats

load _helper
load ellipsis
load fs
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


@test "ellipsis.install should install a new package" {
    skip
}

@test "ellipsis.uninstall should uninstall a package" {
    skip
}

@test "ellipsis.unlink should unlink a package" {
    skip
}

@test "ellipsis.list should list installed packages" {
    skip
}

@test "ellipsis.new should create a new package" {
    skip
}

@test "ellipsis.edit should edit package ellipsis.sh" {
    skip
}

@test "ellipsis.each should run hook for each installed package" {
    skip
}

@test "ellipsis.list_packages should list installed packages" {
    skip
}

@test "ellipsis.list_symlinks should list symlinks to installed packages" {
    skip
}

@test "ellipsis.symlinks should list symlinks to installed packages" {
    skip
}

@test "ellipsis.broken should list broken symlinks in ELLIPSIS_HOME " {
    skip
}

@test "ellipsis.clean should remove broken symlinks from ELLIPSIS_HOME" {
    skip
}

@test "ellipsis.status should show diffstat if changes in packages" {
    skip
}

@test "ellipsis.pull should update packages" {
    skip
}

@test "ellipsis.push should push changes in packages" {
    skip
}
