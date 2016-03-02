#!/usr/bin/env bats

load _helper
load ellipsis
load utils

setup() {
    export ELLIPSIS_HOME="$TESTS_DIR/tmp/ellipsis_home"
    export ELLIPSIS_PACKAGES="$ELLIPSIS_HOME/.ellipsis/packages"
    mkdir -p "$ELLIPSIS_PACKAGES"
    echo 'old' > "$ELLIPSIS_HOME/.file"

    clone_test_package() {
        git clone "$TESTS_DIR/fixtures/dot-test" "$ELLIPSIS_PACKAGES/test" &>/dev/null
    }

    link_test_package() {
        mv "$ELLIPSIS_HOME/.file" "$ELLIPSIS_HOME/.file.bak"
        ln -s "$ELLIPSIS_PACKAGES/test/common/file" "$ELLIPSIS_HOME/.file"
    }

    link_broken() {
        ln -s "$ELLIPSIS_PACKAGES/test/doesnotexist" "$ELLIPSIS_HOME/.doesnotexist"
    }

    modify_test_package() {
        echo modified > "$ELLIPSIS_PACKAGES/test/common/file"
    }

    if [ $BATS_TEST_NUMBER -gt 2 ]; then
        clone_test_package
    fi

    if [ $BATS_TEST_NUMBER -gt 3 ]; then
        link_test_package
    fi

    if [ $BATS_TEST_NUMBER -eq 13 ] || [ $BATS_TEST_NUMBER -eq 14 ]; then
        link_broken
    fi

    if [ $BATS_TEST_NUMBER -eq 15 ]; then
        modify_test_package
    fi
}

teardown() {
    rm -rf "$TESTS_DIR/tmp"
}

@test "ellipsis.install should install package" {
    run ellipsis.install test/fixtures/dot-test
    [ $status -eq 0 ]
    # packages gets installed into packages
    [ -e "$ELLIPSIS_PACKAGES/test/ellipsis.sh" ]
    # creates symlinks
    [ -L "$ELLIPSIS_HOME/.file" ]
    [ "$(readlink "$ELLIPSIS_HOME/.file")" = "$ELLIPSIS_PACKAGES/test/common/file" ]
    # creates backups
    [ -e "$ELLIPSIS_HOME/.file.bak" ]
    [ ! "$(cat "$ELLIPSIS_HOME/.file")" = old ]
    run ellipsis.uninstall test
}

@test "ellipsis.install should install package using branch" {
    run ellipsis.install ellipsis/dot-test2@test-branch
    [ $status -eq 0 ]
    # packages gets installed into packages
    [ -e "$ELLIPSIS_PACKAGES/test2/ellipsis.sh" ]
}

@test "ellipsis.link should link a package" {
    run ellipsis.link test
    [ $status -eq 0 ]
    [ -L "$ELLIPSIS_HOME/.file" ]
}

@test "ellipsis.uninstall should uninstall a package" {
    run ellipsis.uninstall test
    [ $status -eq 0 ]
    [ ! -e "$ELLIPSIS_PACKAGES/test/ellipsis.sh" ]
    [ ! -e "$ELLIPSIS_HOME/.file" ]
}

@test "ellipsis.unlink should unlink a package" {
    run ellipsis.unlink test
    [ $status -eq 0 ]
    [ ! -L "$ELLIPSIS_HOME/.file" ]
}

@test "ellipsis.installed should list installed packages" {
    run ellipsis.installed
    [ $status -eq 0 ]
    [[ "$(utils.strip_colors ${lines[0]})" == ellipsis* ]] || false
    [[ "$(utils.strip_colors ${lines[1]})" == test* ]] || false
}

@test "ellipsis.edit should edit package ellipsis.sh" {
    export EDITOR=cat
    run ellipsis.edit test
    [ $status -eq 0 ]
    [ "${lines[0]}" = "#!/usr/bin/env bash" ]
}

@test "ellipsis.new should create a new package" {
    run ellipsis.new foo
    [ $status -eq 0 ]
    [ -e "$ELLIPSIS_PACKAGES/foo/ellipsis.sh" ]
    [ -e "$ELLIPSIS_PACKAGES/foo/README.md" ]
}

@test "ellipsis.each should run hook for each installed package" {
    run ellipsis.each pkg.run_hook "installed"
    [ $status -eq 0 ]
    [[ "$(utils.strip_colors ${lines[0]})" == ellipsis* ]] || false
    [[ "$(utils.strip_colors ${lines[1]})" == test* ]] || false
}

@test "ellipsis.list_packages should list installed packages" {
    run ellipsis.list_packages
    [ $status -eq 0 ]
    [[ "$output" == "$ELLIPSIS_PACKAGES/test" ]] || false
}

@test "ellipsis.links should list symlinks to installed packages" {
    run ellipsis.links
    [ $status -eq 0 ]
    [[ "${lines[0]}" == test/common/file* ]] || false
}

@test "ellipsis.broken should not list symlinks if none are broken" {
    run ellipsis.broken
    [[ "$output" == "" ]] || false
}

@test "ellipsis.broken should list broken symlinks" {
    run ellipsis.broken
    [[ "$output" == test/doesnotexist* ]] || false
}

@test "ellipsis.clean should remove broken symlinks from ELLIPSIS_HOME" {
    run ellipsis.clean
    [ $status -eq 0 ]
    [ ! -e "$ELLIPSIS_HOME/.doesnotexist" ]
}

@test "ellipsis.status should show diffstat if changes in packages" {
    run ellipsis.status
    [ $status -eq 0 ]
    [[ "$output" = *common/file* ]] || false
}

@test "ellipsis.pull should update packages" {
    skip
    run ellipsis.pull
    [ $status -eq 0 ]
}

@test "ellipsis.push should push changes in packages" {
    skip
    run ellipsis.push
    [ $status -eq 0 ]
}
