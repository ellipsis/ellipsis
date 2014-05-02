#!/usr/bin/env bats

load _helper
load ellipsis

setup() {
    export ELLIPSIS_HOME=$TESTS_DIR/tmp/ellipsis_home
    export ELLIPSIS_PACKAGES=$ELLIPSIS_HOME/.ellipsis/packages
    mkdir -p $ELLIPSIS_PACKAGES
    echo 'old' > $ELLIPSIS_HOME/.ackrc
}

teardown() {
    rm -rf $TESTS_DIR/tmp
}

@test "ellipsis.install should install a new package" {
    run ellipsis.install zeekay/files
    # packages gets installed into packages
    [ -e $ELLIPSIS_PACKAGES/files/ellipsis.sh ]
    # creates symlinks
    [ -e $ELLIPSIS_HOME/.ackrc ]
    [ "$(readlink $ELLIPSIS_HOME/.ackrc)" = "$ELLIPSIS_PACKAGES/files/common/ackrc" ]
    # creates backups
    [ -e $ELLIPSIS_HOME/.ackrc.bak ]
    [ ! "$(cat $ELLIPSIS_HOME/.ackrc)" = old ]
}

@test "ellipsis.uninstall should uninstall a package" {
    skip
}

@test "ellipsis.list should unlink a package" {
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
