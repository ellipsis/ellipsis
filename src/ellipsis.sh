#!/usr/bin/env bash
#
# ellipsis.sh
# Core ellipsis interface.

# Initialize ourselves if we haven't yet.
if [[ $ELLIPSIS_INIT -ne 1 ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")"/init.sh
fi

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

# Installs new ellipsis package, using install hook if one exists. If no hook is
# defined, all files are symlinked into $HOME using `ellipsis.link_files`.
ellipsis.install() {
    case "$1" in
        http:*|https:*|git:*|ssh:*)
            PKG_NAME=$(echo "$1" | rev | cut -d '/' -f 1 | rev)
            PKG_PATH="$(pkg.name_to_path $PKG_NAME)"
            git.clone "$1" "$PKG_PATH"
        ;;
        */*)
	    local user=$(echo $pkg | cut -d '/' -f1)
	    PKG_NAME=$(echo $pkg | cut -d '/' -f2)
            PKG_PATH="$HOME/.ellipsis/packages/$PKG_NAME"
            git.clone "https://github.com/$user/$PKG_NAME" "$PKG_PATH"
        ;;
        *)
            PKG_NAME="$1"
            PKG_PATH="$HOME/.ellipsis/packages/$PKG_NAME"
            git.clone "https://github.com/$ELLIPSIS_USER/$PKG_NAME" "$PKG_PATH"
        ;;
    esac

    pkg.init
    pkg.run pkg.install
    pkg.del
}

# Uninstall ellipsis package, using uninstall hook if one exists. If no hook is
# defined, all symlinked files in $HOME are removed.
ellipsis.uninstall() {
    PKG_PATH="$HOME/.ellipsis/packages/$1"

    pkg.init $PKG_PATH
    pkg.run pkg.uninstall
    pkg.del
}

# List installed packages
ellipsis.list() {
    if utils.cmd_exists column; then
        ellipsis.each pkg.list | column -t -s $'\t'
    else
        ellipsis.each pkg.list
    fi
}

# List available packages using $ELLIPSIS_packageS_URL
ellipsis.available() {
    curl -s $ELLIPSIS_packageS_URL
}

ellipsis.new() {
    if [ $# -eq 1 ]; then
        PKG_PATH="$HOME/.ellipsis/packages/$1"
    else
        PKG_PATH="$(pwd)"
    fi

    PKG_NAME="${PKG_PATH##*/}"

    # create package dir
    mkdir -p $PKG_PATH

    # check if dir is empty
    if ! utils.folder_empty $PKG_PATH; then
        utils.prompt "destination is not empty, continue? [y/n]" || exit 1
    fi

    local escaped_pwd='$(pwd)'

    cat > $PKG_PATH/ellipsis.sh <<EOF
#!/usr/bin/env bash
#
# $PKG_NAME ellipsis package

# The following hooks can be defined to customize behavior of your package:
# pkg.install() {
#     ellipsis.link_files $escaped_pwd
# }

# pkg.push() {
#     git.push
# }

# pkg.pull() {
#     git.pull
# }

# pkg.status() {
#     git.status
# }
EOF

    local prompt=$
    local fence=\`\`\`
    cat > $PKG_PATH/README.md <<EOF
# $PKG_NAME
Just a bunch of dotfiles.

## Install
Clone and symlink or install with [ellipsis][ellipsis]:

$fence
$prompt ellipsis install $PKG_NAME
$fence

[ellipsis]: http://ellipsis.sh
EOF

    cd $PKG_PATH
    git init
    git add README.md ellipsis.sh
    git commit -m "Initial commit"
    echo new package created at ${PKG_PATH/$HOME/\~}
}

# Run commands across all packages.
ellipsis.each() {
    local cwd=$(pwd)
    local cmd="$1"

    # execute command for ellipsis first
    pkg.init $HOME/.ellipsis ellipsis
    pkg.run $cmd
    pkg.del

    # loop over packages, excecuting command
    for package in $(ellipsis.list_packages); do
        pkg.init $package
        pkg.run $cmd
        pkg.del
    done
}

# list all installed packages
ellipsis.list_packages() {
    echo $HOME/.ellipsis/packages/*
}

# list all symlinks, or just symlinks for a given package
ellipsis.symlinks() {
    if [ $# -eq 1 ]; then
        pkg.init $1
        pkg.run pkg.symlinks
        pkg.del
    else
        ellipsis.each pkg.symlinks
    fi
}
