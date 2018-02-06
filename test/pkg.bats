#!/usr/bin/env bats

load _helper
load pkg

setup() {
    mkdir -p tmp/ellipsis_home
    export ELLIPSIS_HOME=tmp/ellipsis_home
}

teardown() {
    rm -rf tmp
}

@test "pkg.split_name should split a package path into a name and a branch" {
    run pkg.split_name "test-package"
    [ "$status" -eq 0 ]
    [ "$output" == "test-package" ]

    run pkg.split_name "test-package@my-tag"
    [ "$status" -eq 0 ]
    [ "$output" == "test-package my-tag" ]
}

@test "pkg.name_stripped should strip the prefix from a package name" {
    run pkg.name_stripped "dot-test"
    [ "$status" -eq 0 ]
    [ "$output" == "test" ]

    run pkg.name_stripped "my-test"
    [ "$status" -eq 0 ]
    [ "$output" == "my-test" ]

    run pkg.name_stripped "my-dot-test"
    [ "$status" -eq 0 ]
    [ "$output" == "my-dot-test" ]
}

@test "pkg.path_from_name should derive package path from package name" {
    run pkg.path_from_name "test"
    [ "$status" -eq 0 ]
    [ "$output" == "$ELLIPSIS_PACKAGES/test" ]
}

@test "pkg.name_from_path should derive package name from package path" {
    run pkg.name_from_path "dot-test"
    [ "$status" -eq 0 ]
    [ "$output" == "dot-test" ]

    run pkg.name_from_path "./custom/path/to/package/dot-test"
    [ "$status" -eq 0 ]
    [ "$output" == "dot-test" ]

    run pkg.name_from_path "/root/path/to/package/dot-test"
    [ "$status" -eq 0 ]
    [ "$output" == "dot-test" ]
}

@test "pkg.name_from_url should derive package name from package url" {
    run pkg.name_from_url "http://github.com/ellipsis/dot-test"
    [ "$status" -eq 0 ]
    [ "$output" == "dot-test" ]

    run pkg.name_from_url "ssh://github.com/ellipsis/dot-test"
    [ "$status" -eq 0 ]
    [ "$output" == "dot-test" ]

    run pkg.name_from_url "ssh://github.com/ellipsis/dot-test"
    [ "$status" -eq 0 ]
    [ "$output" == "dot-test" ]
}

@test "pkg.user_from_shorthand should return the username from shorthand notation" {
    run pkg.user_from_shorthand "user/dot-package"
    [ "$status" -eq 0 ]
    [ "$output" == "user" ]
}

@test "pkg.name_from_shorthand should return the package name from shorthand notation" {
    run pkg.name_from_shorthand "user/dot-package"
    [ "$status" -eq 0 ]
    [ "$output" == "dot-package" ]
}

@test "pkg.set_globals should setup PKG_PATH and PKG_NAME properly" {
    skip "No test implementation"
}

@test "pkg.env_up should setup the package env (vars/hooks)" {
    skip "No test implementation"
}

@test "pkg.list_symlinks should list symlinks for package" {
    skip "No test implementation"
}

@test "pkg.symlinks_mappings should list symlink mappings for package" {
    skip "No test implementation"
}

@test "pkg.run should run command or hook from PKG_PATH" {
    skip "No test implementation"
}

@test "pkg.run_hook should run_hook from PKG_PATH" {
    skip "No test implementation"
}

@test "pkg.env_down should unset the package env (vars/hooks)" {
    skip "No test implementation"
}

@test "pkg.del should unset globals/hooks setup by package initialization" {
    skip "No test implementation"
}
