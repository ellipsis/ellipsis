#!/usr/bin/env bats

load _helper
load ellipsis

setup() {
    export ELLIPSIS_HOME=$TESTS_DIR/tmp/ellipsis_home
    export ELLIPSIS_PACKAGES=$ELLIPSIS_HOME/.ellipsis/packages
    mkdir -p $ELLIPSIS_PACKAGES
    echo 'old' > $ELLIPSIS_HOME/.file

    clone_test_package() {
        git clone $TESTS_DIR/fixtures/dot-test $ELLIPSIS_PACKAGES/test
    }

    link_test_package() {
        mv $ELLIPSIS_HOME/.file $ELLIPSIS_HOME/.file.bak
        ln -s $ELLIPSIS_PACKAGES/test/common/file $ELLIPSIS_HOME/.file
    }

    if [ $BATS_TEST_NUMBER -gt 1 ]; then
        clone_test_package
    fi

    if [ $BATS_TEST_NUMBER -gt 2 ]; then
        link_test_package
    fi
}

teardown() {
    rm -rf $TESTS_DIR/tmp
}

@test "ellipsis.install should install a new package" {
    run ellipsis.install test/fixtures/dot-test
    [ $status -eq 0 ]
    # packages gets installed into packages
    [ -e $ELLIPSIS_PACKAGES/test/ellipsis.sh ]
    # creates symlinks
    [ -e $ELLIPSIS_HOME/.file ]
    [ "$(readlink $ELLIPSIS_HOME/.file)" = "$ELLIPSIS_PACKAGES/test/common/file" ]
    # creates backups
    [ -e $ELLIPSIS_HOME/.file.bak ]
    [ ! "$(cat $ELLIPSIS_HOME/.file)" = old ]
}

@test "ellipsis.link should link a package" {
    run ellipsis.link test
    [ $status -eq 0 ]
    [ -e $ELLIPSIS_HOME/.file ]
}

@test "ellipsis.uninstall should uninstall a package" {
    run ellipsis.uninstall test
    [ $status -eq 0 ]
    [ ! -e $ELLIPSIS_PACKAGES/test/ellipsis.sh ]
    [ ! -e $ELLIPSIS_HOME/.file ]
}

@test "ellipsis.unlink should unlink a package" {
    run ellipsis.unlink test
    [ $status -eq 0 ]
    [ ! -e $ELLIPSIS_HOME/.file ]
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
    run ellipsis.edit test
    [ $status -eq 0 ]
    [ "${lines[0]}" = "#!/usr/bin/env bash" ]
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
