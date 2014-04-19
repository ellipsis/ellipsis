#!/usr/bin/env bash
#
# core ellipsis functions

# These globals can be set by a user to use a custom ellipsis fork/set of modules
ELLIPSIS_USER="${ELLIPSIS_USER:-zeekay}"
ELLIPSIS_REPO="${ELLIPSIS_REPO:-https://github.com/$ELLIPSIS_USER/ellipsis}"
ELLIPSIS_MODULES_URL="${ELLIPSIS_MODULES_URL:-https://raw.githubusercontent.com/$ELLIPSIS_USER/ellipsis/master/available-modules.txt}"

# platform detection
ellipsis.platform() {
    uname | tr '[:upper:]' '[:lower:]'
}

# backup existing file, ensuring you don't overwrite existing backups
ellipsis.backup() {
    original="$1"
    backup="$original.bak"
    name="${original##*/}"

    # check for broken symlinks
    if [ "$(find -L "$original" -maxdepth 0 -type l 2>/dev/null)" != "" ]; then
        broken=$(readlink "$original")

        if [ "$(echo "$broken" | grep .ellipsis)" != "" ]; then
            # silently remove old broken ellipsis symlinks
            rm "$original"
        else
            # notify user we're removing a broken link
            echo "rm ~/$name (broken link to $broken)"
            rm "$original"
        fi

        return
    fi

    if [ -e "$original" ]; then
        # remove, not backup old ellipsis symlinked files
        if [ "$(readlink "$original" | grep .ellipsis)" != "" ]; then
            rm "$original"
            return
        fi

        if [ -e "$backup" ]; then
            n=1
            while [ -e "$backup.$n" ]; do
                n=$((n+1))
            done
            backup="$backup.$n"
        fi

        echo "mv ~/$name $backup"
        mv "$original" "$backup"
    fi
}

# run web-based installers in github repo
ellipsis.run_installer() {
    # save reference to current dir
    cwd=$(pwd)
    # create temp dir and cd to it
    tmp_dir=$(mktemp -d) && cd $tmp_dir

    # download installer
    curl -s "$url" > "tmp-$$.sh"
    # run with ELLIPSIS env var set
    ELLIPSIS=1 sh "tmp-$$.sh"

    # change back to original dir and clean up
    cd $cwd
    rm -rf $tmp_dir
}

# symlink a single file into $HOME
ellipsis.link_file() {
    name="${$1##*/}"
    dest="~/.$name"

    backup "$dest"

    echo linking "$dest"
    ln -s "$1" "$dest"
}

# find all files in dir excluding the dir itself, hidden files, README,
# LICENSE, *.rst, *.md, and *.txt and symlink into $HOME.
ellipsis.link_files() {
    for file in $(find "$1" -maxdepth 1 -name '*' \
                                      ! -name '.*' \
                                      ! -name 'README' \
                                      ! -name 'LICENSE' \
                                      ! -name '*.md' \
                                      ! -name '*.rst' \
                                      ! -name '*.txt' \
                                      ! -name "$1" \
                                      ! -name "ellipsis.sh" | sort); do
        ellipsis.link_file $file
    done
}

# Installs new ellipsis module, using install hook if one exists. If no hook is
# defined, all files are symlinked into $HOME using `ellipsis.link_files`.
#
# Following variables are available from your hook:
#   $mod_name Name of your module
#   $mod_path Path to your module
ellipsis.install() {
    case $mod in
        http:*|https:*|git:*|ssh:*)
            mod_name=$(echo "$1" | rev | cut -d '/' -f 1 | rev)
            mod_path="~/.ellipsis/modules/$mod_name"
            git.clone "$1" "$mod_path"
        ;;
        github:*)
            user=$(echo "$1" | cut -d ':' -f 2 | cut -d '/' -f 1)
            mod_name=$(echo "$1" | cut -d ':' -f 2 | cut -d '/' -f 2)
            mod_path="~/.ellipsis/modules/$mod_name"
            git.clone "https://github.com/$user/$mod_name" "$mod_path"
        ;;
        *)
            mod_name="$1"
            mod_path="~/.ellipsis/modules/$mod_name"
            git.clone "https://github.com/$ELLIPSIS_USER/dot-$mod_name" "$mod_path"
        ;;
    esac

    # source ellipsis module
    source "$mod_path/ellipsis.sh"

    # run install hook if available, otherwise link files in place
    if hash mod.install 2>/dev/null; then
        mod.install
    else
        ellipsis.link_files $mod_path
    fi
}

# List available modules using $ELLIPSIS_MODULES_URL
ellipsis.list() {
    curl -s $ELLIPSIS_MODULES_URL
}

# Run commands across all modules.
ellipsis.do() {
    # execute command for ellipsis first
    eval "${1}" ~/.ellipsis

    # loop over modules, excecuting command
    for module in ~/.ellipsis/modules/*; do
        mod_path=$module
        mod_name=${module##*/}
        original_cwd=$(pwd)

        # change to mod_path and source module
        cd $mod_path

        # modules are not required to have an ellipsis.sh file
        if [ -f ellipsis.sh ]; then
            source "ellipsis.sh"
        fi

        # use module hooks if it exists
        if hash mod.$1 2>/dev/null; then
            mod.$1
        else
            $1
        fi

        # unset any hooks that might be defined
        unset -f mod.install
        unset -f mod.pull
        unset -f mod.push
        unset -f mod.status

        # return to original cwd
        cd $original_cwd
    done
}
