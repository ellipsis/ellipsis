#!/usr/bin/env bats

load _helper
load ellipsis

setup() {
    mkdir -p tmp/ellipsis_home
    export ELLIPSIS_HOME=tmp/ellipsis_home
}

teardown() {
    rm -rf tmp
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
