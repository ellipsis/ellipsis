#!/usr/bin/env bash
#
# Just a little helper file for bats.

TESTS_DIR=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)

# Replace bat's load with one that sources sh files.
load() {
    source $TESTS_DIR/$1.sh
}
