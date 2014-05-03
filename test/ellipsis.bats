#!/usr/bin/env bats

load _helper
load ellipsis

mock_package() {
    cp -rf test/fixtures/test-package $ELLIPSIS_PACKAGES/test
    cp -rf test/fixtures/test-package/.git $ELLIPSIS_PACKAGES/test
}

mock_package_install() {
    mv $ELLIPSIS_HOME/.ackrc $ELLIPSIS_HOME/.ackrc.bak
    ln -s $ELLIPSIS_PACKAGES/file/common/ackrc $ELLIPSIS_HOME/.ackrc
}

setup() {
    export ELLIPSIS_HOME=$TESTS_DIR/tmp/ellipsis_home
    export ELLIPSIS_PACKAGES=$ELLIPSIS_HOME/.ellipsis/packages
    mkdir -p $ELLIPSIS_PACKAGES
    echo 'old' > $ELLIPSIS_HOME/.ackrc

    if [ $BATS_TEST_NUMBER -eq 2 ]; then
        mock_package
    fi

    if [ $BATS_TEST_NUMBER -gt 1 ]; then
        mock_package_install
    fi
}

teardown() {
    rm -rf $TESTS_DIR/tmp
}

@test "ellipsis.install should install a new package" {
    run ellipsis.install zeekay/files
    [ $status -eq 0 ]
    # packages gets installed into packages
    [ -e $ELLIPSIS_PACKAGES/files/ellipsis.sh ]
    # creates symlinks
    [ -e $ELLIPSIS_HOME/.ackrc ]
    [ "$(readlink $ELLIPSIS_HOME/.ackrc)" = "$ELLIPSIS_PACKAGES/files/common/ackrc" ]
    # creates backups
    [ -e $ELLIPSIS_HOME/.ackrc.bak ]
    [ ! "$(cat $ELLIPSIS_HOME/.ackrc)" = old ]
}

@test "ellipsis.link should link a package" {
    run ellipsis.link files
    [ $status -eq 0 ]
    [ -e $ELLIPSIS_HOME/.ackrc ]
}

@test "ellipsis.uninstall should uninstall a package" {
    run ellipsis.uninstall files
    [ $status -eq 0 ]
    [ ! -e $ELLIPSIS_PACKAGES/files/ellipsis.sh ]
    [ ! -e $ELLIPSIS_HOME/.ackrc ]
}

@test "ellipsis.unlink should unlink a package" {
    run ellipsis.unlink files
    [ $status -eq 0 ]
    [ ! -e $ELLIPSIS_HOME/.ackrc ]
}

@test "ellipsis.installed should list installed packages" {
    run ellipsis.installed
    [ $status -eq 0 ]
}

@test "ellipsis.new should create a new package" {
    skip
}

@test "ellipsis.edit should edit package ellipsis.sh" {
    export EDITOR=cat
    run ellipsis.edit files
    [ $status -eq 0 ]
    [ "${lines[0]}" = "pkg.link() { fs.link_files common }" ]
}

@test "ellipsis.each should run hook for each installed package" {
    run ellipsis.each git.status
    [ $status -eq 0 ]
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
