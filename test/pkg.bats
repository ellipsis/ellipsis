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

@test "pkg.name_from_path should derive package name from package path" {
    skip "No test implementation"
}

@test "pkg.path_from_name should derive package path from package name" {
    skip "No test implementation"
}

@test "pkg.init_globals should setup PKG_PATH and PKG_NAME properly" {
    skip "No test implementation"
}

@test "pkg.init should initialize globals for package and source hooks" {
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

@test "pkg.del should unset globals/hooks setup by package initialization" {
    skip "No test implementation"
}

@test "pkg.del should unset globals/hooks setup by package initialization" {
    skip "No test implementation"
}
