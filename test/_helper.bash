#!/usr/bin/env bash
#
# test/_helper.bash
# Just a little helper file for bats.

# Set path vars
export TESTS_DIR="$BATS_TEST_DIRNAME"
export ELLIPSIS_PATH="$(cd "$TESTS_DIR/.." && pwd)"
export ELLIPSIS_SRC="$ELLIPSIS_PATH/src"
export PATH="$ELLIPSIS_PATH/bin:$PATH"

# Don't log tests
export ELLIPSIS_LOGFILE="/dev/null"

# Reset nesting level
export ELLIPSIS_LVL=0

# Initialize ellipsis, which replaces bat's `load` function with ours.
load ../src/init
