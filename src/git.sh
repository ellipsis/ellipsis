#!/usr/bin/env bash
#
# git.sh
# Assorted git utility functions. These functions all require us to cd into the
# git repo we want to operate on first. These exist mostly for aesthetic
# reasons, i.e., pretty output in the various ellipsis commands and can be used
# by package authors for consistency with them.

# Initialize ourselves if we haven't yet.
if [[ $ELLIPSIS_INIT -ne 1 ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")"/init.sh
fi

# Clone a Git repo.
git.clone() {
    git clone --depth 1 "$@" 2>&1 | grep 'Cloning into'
}

# Pull git repo.
git.pull() {
    echo -e "\033[1mupdating $PKG_NAME\033[0m"
    git pull
}

# Push git repo.
git.push() {
    echo -e "\033[1mpushing $PKG_NAME\033[0m"
    git push
}

# Tab delimited package listing with commit/last update time.
git.list() {
    local sha1=$(git.sha1)
    local last_updated=$(git.last_updated)

    echo -e "\033[1m$PKG_NAME\033[0m\t$sha1\t(updated $last_updated)"
}

# Pretty status with diff.
git.status() {
    local ahead="$(git.ahead)"

    if ! git.has_changes || [ ! -z "$ahead" ]; then
        return
    fi

    local sha1="$(git.sha1)"
    local last_updated=$(git.last_updated)

    echo -e "\033[1m$PKG_NAME\033[0m $sha1 (updated $last_updated) $ahead"
    git.diffstat
}

# Print last commit's sha1 hash.
git.sha1() {
    git rev-parse --short HEAD
}

# Print last commit's relative update time.
git.last_updated() {
    git --no-pager log --pretty="format:%ad" --date=relative -1
}

# Print how far ahead git repo is
git.ahead() {
    git status -sb --porcelain | grep --color=no -o '\[.*\]'
}

# Check whether get repo has changes.
git.has_changes() {
    if  [ -z "$(git --untracked-files=no --porcelain 2> /dev/null | tail -n 1)" ]; then
	    return 0
    fi
    return 1
}

# Print diffstat for git repo
git.diffstat() {
    git --no-pager diff --stat --color=always
}
