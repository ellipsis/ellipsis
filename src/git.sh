#!/usr/bin/env bash
#
# assorted git utility functions

# git wrappers
git.clone() {
    git clone --depth 1 "$1" "$2" 2>&1 | grep 'Cloning into'
}

git.pull() {
    local cwd="$(pwd)"
    if [ "$#" -eq 1 ]; then
        mod_name="${1##*/}"
        cd "$1"
    fi

    echo -e "\033[1mupdating $mod_name\033[0m" | sed 's/\-e //'

    git pull

    cd "$cwd"
}

git.push() {
    local cwd="$(pwd)"
    if [ "$#" -eq 1 ]; then
        mod_name="${1##*/}"
        cd "$1"
    fi

    echo -e "\033[1mpushing $mod_name\033[0m" | sed 's/\-e //'

    git push

    cd "$cwd"
}

git.status() {
    local cwd="$(pwd)"
    if [ "$#" -eq 1 ]; then
        mod_name="${1##*/}"
        cd "$1"
    fi

    local ahead=$(git status -sb --porcelain | grep --color=no -o '\[.*\]')
    local has_changes=$(git status --untracked-files=no --porcelain 2> /dev/null | tail -n1)
    [[ "$ahead" = "" ]] && [[ "$has_changes" = "" ]] && return

    echo -e "\033[1m$mod_name\033[0m $(git --no-pager log --pretty=format:'%h %ad' --abbrev-commit --date=relative -1) $ahead" | sed 's/\-e //'

    git --no-pager diff --stat --color=always

    cd "$cwd"
}
