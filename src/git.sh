#!/usr/bin/env bash
#
# assorted git utility functions

# git wrappers
git.clone() {
    git clone --depth 1 "$1" "$2" 2>&1 | grep 'Cloning into'
}

git.pull() {
    name=$(echo "${1##*/}" | sed 's/^\.//')
    cd "$1"

    echo -e "\033[1mupdating $name\033[0m" | sed 's/\-e //'

    git pull
}

git.push() {
    name=$(echo "${1##*/}" | sed 's/^\.//')
    cd "$1"

    echo -e "\033[1mpushing $name\033[0m" | sed 's/\-e //'

    git push
}

git.status() {
    name=$(echo "${1##*/}" | sed 's/^\.//')
    cd "$1"

    ahead=$(git status -sb --porcelain | grep --color=no -o '\[.*\]')
    has_changes=$(git status --untracked-files=no --porcelain 2> /dev/null | tail -n1)
    [[ "$ahead" = "" ]] && [[ "$has_changes" = "" ]] && return

    echo -e "\033[1m$name\033[0m $(git --no-pager log --pretty=format:'%h %ad' --abbrev-commit --date=relative -1) $ahead" | sed 's/\-e //'

    git --no-pager diff --stat --color=always
}
