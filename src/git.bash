# git.bash
#
# Assorted git utility functions. These functions all require us to cd into the
# git repo we want to operate on first. These exist mostly for aesthetic
# reasons, i.e., pretty output in the various ellipsis commands and can be used
# by package authors for consistency with them.

load pkg

# Clone a Git repo.
git.clone() {
    if [ -z "$2" ]; then
        git clone --depth 1 "$1"
    elif [ -z "$3" ]; then
        git clone --depth 1 "$1" "$2"
    else
        git clone --depth 1 "$1" "$2" --branch "$3"
    fi
}

# Pull git repo.
git.pull() {
    pkg.init_globals ${1:-$PKG_NAME}
    echo -e "\033[1mupdating $PKG_NAME\033[0m"
    git pull
}

# Push git repo.
git.push() {
    pkg.init_globals ${1:-$PKG_NAME}
    echo -e "\033[1mpushing $PKG_NAME\033[0m"
    git push
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
    git status -sb --porcelain | grep -o '\[.*\]'
}

# Check whether get repo has changes.
git.has_changes() {
    if git diff-index --quiet HEAD --; then
        return 1
    fi
    return 0
}

# Print diffstat for git repo
git.diffstat() {
    git --no-pager diff --stat --color=always
}

# Checks if git is configured as we expect.
git.configured() {
    for key in user.name user.email github.user; do
        if [ -z "$(git config --global $key | cat)"  ]; then
            return 1
        fi
    done
    return 0
}

# Adds an include safely.
git.add_include() {
    git config --global --unset-all include.path $1
    if [ -z "$(git config --global include.path)" ]; then
        git config --global --remove-section include &>/dev/null
    fi
    git config --global --add include.path $1
}
