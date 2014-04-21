#!/usr/bin/env bash
#
# Just a little helper file for bats.

export TESTS_DIR=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
export PATH=$TESTS_DIR/..bin:$PATH

# Replace bat's load with one that sources sh files.
load() {
    source $TESTS_DIR/../src/$1.sh
}
