#!/usr/bin/env bash
#
# test/_helper.bash
# Just a little helper file for bats.

export TESTS_DIR="$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)"
export PATH="$TESTS_DIR/../bin:$PATH"

# Initialize ellipsis, which replaces bat's `load` function with ours.
load ../src/init

# Install ourselves for Travis CI
if [ "$TRAVIS" ] && [ ! -e "/home/travis/.ellipsis" ]; then
    ln -s /home/travis/build/zeekay/ellipsis /home/travis/.ellipsis
fi
