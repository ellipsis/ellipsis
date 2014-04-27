#!/usr/bin/env bats

load _helper
load ellipsis
load utils

# setup() {
# }
#
# teardown() {
# }

@test "ellipsis.backup should make a backup of a file that exists" {
    skip
    run ellipsis.backup some_file
    [ $status -eq 0 ]
}

@test "ellipsis.link_file should link a file into HOME" {
    skip
    run ellipsis.link some_file
    [ $status -eq 0 ]
}

@test "ellipsis.link_files should link all the files in folder into HOME" {
    skip
    run utils.link_files folder
    [ $status -eq 0 ]
}
