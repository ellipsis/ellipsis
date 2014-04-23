#!/usr/bin/env bash
#
# assorted git utility functions

# globals
ellipsis_path=${ellipsis_path:-$HOME/.ellipsis}
pkg_path=${pkg_path:-$ellipsis_path}
pkg_name=${pkg_name##*/.}

git.clone() {
    git --work-tree="$mod_path" clone --depth 1 "$1" "$2" 2>&1 | grep 'Cloning into'
}

git.pull() {
    echo -e "\033[1mupdating $mod_name\033[0m" | sed 's/\-e //'
    git --work-tree="$mod_path" pull
}

git.push() {
    echo -e "\033[1mpushing $mod_name\033[0m" | sed 's/\-e //'
    git --work-tree="$mod_path" push
}

git.status() {
    local ahead=$(git status -sb --porcelain | grep --color=no -o '\[.*\]')
    local has_changes=$(git status --untracked-files=no --porcelain 2> /dev/null | tail -n1)
    [[ "$ahead" = "" ]] && [[ "$has_changes" = "" ]] && return
    echo -e "\033[1m$mod_name\033[0m $(git --no-pager log --pretty=format:'%h (updated %ad)' --abbrev-commit --date=relative -1) $ahead" | sed 's/\-e //'
    git --work-tree="$mod_path" --no-pager diff --stat --color=always
}

git.list() {
    echo -e "\033[1m$mod_name\033[0m\t$(git --no-pager log --pretty=format:'%h\t(updated %ad)' --abbrev-commit --date=relative -1)" | sed 's/\-e //'
}

git.sha1() {
    local work_tree="${1:-$PKG_PATH}"

    git --work-tree="$work_tree" rev-parse --short HEAD
}

git.last_updated() {
    local work_tree="${1:-$PKG_PATH}"

    git --no-pager log --pretty="format:%ad" --date=relative -1
}
