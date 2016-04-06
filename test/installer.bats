#!/usr/bin/env bats
#
# Tests for the installation script

setup() {
    export TESTS_DIR="$BATS_TEST_DIRNAME"

    mkdir -p "$TESTS_DIR/tmp"
    export ELLIPSIS_PATH="$(cd "$TESTS_DIR/tmp" && pwd)/ellipsis"
}

teardown() {
    rm -rf "$TESTS_DIR/tmp"
}

@test "Installer detects missing dependencies" {
    # Setup
    mkdir -p "$TESTS_DIR/tmp/bin/no_bash"
    touch "$TESTS_DIR/tmp/bin/no_bash/curl"
    touch "$TESTS_DIR/tmp/bin/no_bash/git"

    mkdir -p "$TESTS_DIR/tmp/bin/no_curl"
    touch "$TESTS_DIR/tmp/bin/no_curl/bash"
    touch "$TESTS_DIR/tmp/bin/no_curl/git"

    mkdir -p "$TESTS_DIR/tmp/bin/no_git"
    touch "$TESTS_DIR/tmp/bin/no_git/bash"
    touch "$TESTS_DIR/tmp/bin/no_git/curl"

    chmod -R +x "$TESTS_DIR/tmp/bin"

    export BASH="$(which bash)"

    # Bash
    PATH="$TESTS_DIR/tmp/bin/no_bash"\
    run "$BASH" scripts/install.bash
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "ellipsis requires bash to be installed." ]

    # Curl
    PATH="$TESTS_DIR/tmp/bin/no_curl"\
    run "$BASH" scripts/install.bash
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "ellipsis requires curl to be installed." ]

    # Git
    PATH="$TESTS_DIR/tmp/bin/no_git"\
    run "$BASH" scripts/install.bash
    [ "$status" -eq 1 ]
    [ "${lines[0]}" = "ellipsis requires git to be installed." ]
}

@test "Installer fails in a clean way when cloning fails" {
    ELLIPSIS_REPO="https://ellipsis:not_valid@github.com/ellipsis/not_valid"\
    run scripts/install.bash

    # Check output status
    [ "$status" -eq 1 ]

    # Check messages
    [ $(expr "$output" : ".*Installation failed!") -ne 0 ]
    [ $(expr "$output" : '.*Please check $ELLIPSIS_REPO and try again!') -ne 0 ]
}

@test "Installer fails in a clean way when copying ellipsis fails" {
    # stderr output is disabled to remove git progress messages
    ELLIPSIS_PATH="$TESTS_DIR/tmp/not_valid/not_valid"\
    ELLIPSIS_REPO="https://github.com/ellipsis/installer-test"\
    run scripts/install.bash 2> /dev/null

    # Check output status
    [ "$status" -eq 1 ]

    # Check messages
    [ $(expr "$output" : ".*Installation failed!") -ne 0 ]
    [ $(expr "$output" : '.*Please check $ELLIPSIS_PATH and try again!') -ne 0 ]
}

# Tests multiple things to avoid unnecessary cloning
@test "Installer correctly 'installs' test project" {
    # stderr output is disabled to remove git progress messages
    PACKAGES="test1 test2"\
    ELLIPSIS_REPO="https://github.com/ellipsis/installer-test"\
    run scripts/install.bash 2> /dev/null

    # Exit status should be ok
    [ "$status" -eq 0 ]

    # Check if `$ELLIPSIS_PATH` is set correctly
    [ $(expr "$output" : ".*Ellipsis path : $TESTS_DIR/tmp/ellipsis") -ne 0 ]
    #[ "${lines[2]}" = "Ellipsis path : $TESTS_DIR/tmp/ellipsis" ]

    # Check if project is installed
    [ -f "$TESTS_DIR/tmp/ellipsis/installer-test" ]

    # Check if libs get loaded
    [ $(expr "$output" : ".*load : ellipsis") -ne 0 ]
    [ $(expr "$output" : ".*load : fs") -ne 0 ]
    [ $(expr "$output" : ".*load : os") -ne 0 ]
    [ $(expr "$output" : ".*load : msg") -ne 0 ]
    [ $(expr "$output" : ".*load : log") -ne 0 ]

    # Check if fs.backup is called on the correct dir
    [ $(expr "$output" : ".*fs.backup : $TESTS_DIR/tmp/ellipsis") -ne 0 ]

    # Check if packages would be installed
    [ $(expr "$output" : ".*Installing test1") -ne 0 ]
    [ $(expr "$output" : ".*ellipsis.install : test1") -ne 0 ]
    [ $(expr "$output" : ".*Installing test2") -ne 0 ]
    [ $(expr "$output" : ".*ellipsis.install : test2") -ne 0 ]
}

@test "Installer correctly installs ellipsis" {
    # Add ellipsis dir to check backup function
    mkdir -p "$TESTS_DIR/tmp/ellipsis"

    # Script runs without errors
    run scripts/install.bash
    [ "$status" -eq 0 ]

    # Original ellipsis dir is preserved
    [ -d "$TESTS_DIR/tmp/ellipsis.bak" ]

    # Ellipsis is installed and masks possible local installations
    PATH="$TESTS_DIR/tmp/ellipsis/bin:$PATH"\
    run which ellipsis
    [ "$status" -eq 0 ]
    [ "$output" = "$TESTS_DIR/tmp/ellipsis/bin/ellipsis" ]

    # The installed ellipsis version runs without errors
    PATH="$TESTS_DIR/tmp/ellipsis/bin:$PATH"\
    run ellipsis version
    [ "$status" -eq 0 ]
    [ $(expr "$output" : "v[0-9][0-9.]*") -ne 0 ]
}

