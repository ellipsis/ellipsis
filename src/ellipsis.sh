#!/usr/bin/env bash

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

# run installer scripts/install.sh in github repo
ellipsis.run_installer() {
    # case $mod in
    #     http:*|https:*|git:*|ssh:*)
    # esac
    url="https://raw.githubusercontent.com/$1/master/scripts/install.sh"
    curl -s "$url" > "$1-install-$$.sh"
    ELLIPSIS=1 sh "$1-install-$$.sh"
    rm "$1-install-$$.sh"
}

# links files in module repo into home folder
ellipsis.link_files() {
    for dotfile in $(find "$1" -maxdepth 1 -name '*' ! -name '.*' | sort); do
        # ignore containing directory, ellipsis.sh and any *.md or *.rst files
        if [ "$dotfile" != "$1" && ellipsis.sh ]; then
            name="${dotfile##*/}"
            dest="~/.$name"

            backup "$dest"

            echo linking "$dest"
            ln -s "$dotfile" "$dest"
        fi
    done
}

# Install a new ellipsis module, running install hook if defined.
# Following variables are available from your hook:
#   $mod_name - name of your module
#   $mod_path - path to your module
# If no hook is defined, all files are symlinked into $HOME using ellipsis.link_files
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
            git.clone "https://github.com/zeekay/dot-$mod_name" "$mod_path"
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

# run command across all modules
ellipsis.do() {
    eval "${1}" ~/.ellipsis

    for module in ~/.ellipsis/modules/*; do
        if [ -e "$module/.ellipsis/$1" ]; then
            module_path=$module
            module=${module##*/}
            . "$module_path/.ellipsis/$1"
        fi
    done
}
