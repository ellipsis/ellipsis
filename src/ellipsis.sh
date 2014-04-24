#!/usr/bin/env bash
#
# ellipsis.sh
# Core ellipsis interface.

# Source globals if they haven't been yet
if [[ $ELLIPSIS_GLOBALS -ne 1 ]]; then
    source $(dirname "${BASH_SOURCE[0]}")/globals.sh
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
            mod_name=$(echo "$1" | rev | cut -d '/' -f 1 | rev)
            mod_path="$(mod.name_to_path $mod_name)"
            git.clone "$1" "$mod_path"
        ;;
        github:*)
            user=$(echo "$1" | cut -d ':' -f 2 | cut -d '/' -f 1)
            mod_name=$(echo "$1" | cut -d ':' -f 2 | cut -d '/' -f 2)
            mod_path="$HOME/.ellipsis/packages/$mod_name"
            git.clone "https://github.com/$user/$mod_name" "$mod_path"
        ;;
        *)
            mod_name="$1"
            mod_path="$HOME/.ellipsis/packages/$mod_name"
            git.clone "https://github.com/$ELLIPSIS_USER/dot-$mod_name" "$mod_path"
        ;;
    esac

    mod.init
    mod.run mod.install
    mod.del
}

# Uninstall ellipsis package, using uninstall hook if one exists. If no hook is
# defined, all symlinked files in $HOME are removed.
ellipsis.uninstall() {
    mod_path="$HOME/.ellipsis/packages/$1"

    mod.init $mod_path
    mod.run mod.uninstall
    mod.del
}

# List installed packages
ellipsis.list() {
    if utils.cmd_exists column; then
        ellipsis.each mod.list | column -t -s $'\t'
    else
        ellipsis.each mod.list
    fi
}

# List available packages using $ELLIPSIS_packageS_URL
ellipsis.available() {
    curl -s $ELLIPSIS_packageS_URL
}

ellipsis.new() {
    if [ $# -eq 1 ]; then
        mod_path="$HOME/.ellipsis/packages/$1"
    else
        mod_path="$(pwd)"
    fi

    mod_name="${mod_path##*/}"

    # create package dir
    mkdir -p $mod_path

    # check if dir is empty
    if ! utils.folder_empty $mod_path; then
        utils.prompt "destination is not empty, continue? [y/n]" || exit 1
    fi

    local escaped_pwd='$(pwd)'

    cat > $mod_path/ellipsis.sh <<EOF
#!/usr/bin/env bash
#
# $mod_name ellipsis package

# The following hooks can be defined to customize behavior of your package:
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
    echo new package created at ${mod_path/$HOME/\~}
}

# Run commands across all packages.
ellipsis.each() {
    local cwd=$(pwd)
    local cmd="$1"

    # execute command for ellipsis first
    mod.init $HOME/.ellipsis ellipsis
    mod.run $cmd
    mod.del

    # loop over packages, excecuting command
    for package in $(ellipsis.list_packages); do
        mod.init $package
        mod.run $cmd
        mod.del
    done
}

# list all installed packages
ellipsis.list_packages() {
    echo $HOME/.ellipsis/packages/*
}

# list all symlinks, or just symlinks for a given package
ellipsis.symlinks() {
    if [ $# -eq 1 ]; then
        mod.init $1
        mod.run mod.symlinks
        mod.del
    else
        ellipsis.each mod.symlinks
    fi
}
