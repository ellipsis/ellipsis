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
    local original="$1"
    local backup="$original.bak"
    local name="${original##*/}"

    # check for broken symlinks
    if [ "$(find -L "$original" -maxdepth 0 -type l 2>/dev/null)" != "" ]; then
        local broken=$(readlink "$original")

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
    local cwd=$(pwd)
    # create temp dir and cd to it
    local tmp_dir=$(mktemp -d $TMPDIR.XXXXXX) && cd $tmp_dir

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
    local name="${1##*/}"
    local dest="$HOME/.$name"

    ellipsis.backup "$dest"

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
                                      ! -wholename "$1" \
                                      ! -name "ellipsis.sh" | sort); do
        ellipsis.link_file $file
    done
}

# Find any files that originate from this path and rm symlinks to them in $HOME.
ellipsis.unlink_files() {
    for file in $(find "$HOME" -maxdepth 1 -name '*' \
                                         ! -name '.*' \
                                         ! -name 'README' \
                                         ! -name 'LICENSE' \
                                         ! -name '*.md' \
                                         ! -name '*.rst' \
                                         ! -name '*.txt' \
                                         ! -name "$1" \
                                         ! -name "ellipsis.sh" | sort); do
        rm $file
    done
}

# Installs new ellipsis module, using install hook if one exists. If no hook is
# defined, all files are symlinked into $HOME using `ellipsis.link_files`.
ellipsis.install() {
    case "$1" in
        http:*|https:*|git:*|ssh:*)
            mod_name=$(echo "$1" | rev | cut -d '/' -f 1 | rev)
            mod_path="$HOME/.ellipsis/modules/$mod_name"
            git.clone "$1" "$mod_path"
        ;;
        github:*)
            user=$(echo "$1" | cut -d ':' -f 2 | cut -d '/' -f 1)
            mod_name=$(echo "$1" | cut -d ':' -f 2 | cut -d '/' -f 2)
            mod_path="$HOME/.ellipsis/modules/$mod_name"
            git.clone "https://github.com/$user/$mod_name" "$mod_path"
        ;;
        *)
            mod_name="$1"
            mod_path="$HOME/.ellipsis/modules/$mod_name"
            git.clone "https://github.com/$ELLIPSIS_USER/dot-$mod_name" "$mod_path"
        ;;
    esac

    local cwd="$(pwd)"

    # change to mod_path and source module
    cd $mod_path

    # source ellipsis module
    if [ -f ellipsis.sh ]; then
        source "ellipsis.sh"
    fi

    # run install hook if available, otherwise link files in place
    if utils.cmd_exists mod.install; then
        mod.install
    else
        ellipsis.link_files $mod_path
    fi

    # unset any hooks that might be defined
    unset -f mod.install
    unset -f mod.pull
    unset -f mod.push
    unset -f mod.status

    # return to original cwd
    cd $cwd
}

# Uninstall ellipsis module, using uninstall hook if one exists. If no hook is
# defined, all symlinked files in $HOME are removed.
ellipsis.uninstall() {
    mod_name="$1"
    mod_path="$HOME/.ellipsis/modules/$mod_name"

    find $HOME -type l -name '.*' -maxdepth 1 | xargs readlink | grep ellipsis/modules/$name

    # source ellipsis module
    source "$mod_path/ellipsis.sh"

    # run install hook if available, otherwise link files in place
    if utils.cmd_exists mod.uninstall; then
        mod.uninstall
    else
        ellipsis.unlink_files $mod_path
    fi
}

# List installed modules
ellipsis.list() {
    ellipsis.do list
}

# List available modules using $ELLIPSIS_MODULES_URL
ellipsis.available() {
    curl -s $ELLIPSIS_MODULES_URL
}

ellipsis.new() {
    if [ $# -eq 1 ]; then
        mod_path="$HOME/.ellipsis/modules/$1"
    else
        mod_path="$(pwd)"
    fi

    mod_name="${mod_path##*/}"

    # create module dir
    mkdir -p $mod_path

    # check if dir is empty
    if ! utils.folder_is_empty $mod_path; then
        utils.prompt "destination is not empty, continue? [y/n]" || exit 1
    fi

    local escaped_pwd='$(pwd)'

    cat > $mod_path/ellipsis.sh <<EOF
#!/usr/bin/env bash
#
# $mod_name ellipsis module

# The following hooks can be defined to customize behavior of your module:
# mod.install() {
#     ellipsis.link_files $escaped_pwd
# }

# mod.push() {
#     git.push
# }

# mod.pull() {
#     git.pull
# }

# mod.status() {
#     git.status
# }
EOF

    local prompt=$
    local fence=\`\`\`
    cat > $mod_path/README.md <<EOF
# $mod_name
Just a bunch of dotfiles.

## Install
Clone and symlink or install with [ellipsis][ellipsis]:

$fence
$prompt ellipsis install $mod_name
$fence

[ellipsis]: http://ellipsis.sh
EOF

    cd $mod_path
    git init
    git add README.md ellipsis.sh
    git commit -m "Initial commit"
    echo new module created at ${mod_path/$HOME/\~}
}

# Run commands across all modules.
ellipsis.do() {
    local cwd=$(pwd)

    # execute command for ellipsis first
    mod_name=ellipsis
    mod_path=$HOME/.ellipsis
    cd $mod_path
    eval "git.${1}"
    cd "$cwd"

    # loop over modules, excecuting command
    for module in "$HOME/.ellipsis/modules/"*; do
        mod_path=$module
        mod_name=${module##*/}

        # change to mod_path and source module
        cd $mod_path

        # modules are not required to have an ellipsis.sh file
        if [ -f "ellipsis.sh" ]; then
            source "ellipsis.sh"
        fi

        # use module hooks if it exists
        if utils.cmd_exists mod.$1; then
            mod.$1
        else
            git.$1 $mod_path
        fi

        # unset any hooks that might be defined
        unset -f mod.install
        unset -f mod.pull
        unset -f mod.push
        unset -f mod.status

        # return to original cwd
        cd $cwd
    done
}
