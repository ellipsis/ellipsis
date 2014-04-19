#!/bin/sh

hash git 2>/dev/null || { echo >&2 "sorry bub, ellipsis requires git installed."; exit 1; }

UNAME="$(uname | tr '[:upper:]' '[:lower:]')"

backup() {
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

git_clone() {
    git clone --depth 1 "$1" "$2" 2>&1 | grep 'Cloning into'
}

run_installer() {
    curl -s "https://raw.github.com/zeekay/$1/master/scripts/install.sh" > "$1-install-$$.sh"
    ELLIPSIS_INSTALL=1 sh "$1-install-$$.sh"
    rm "$1-install-$$.sh"
}

link_files() {
    for dotfile in $(find "$1" -maxdepth 1 -name '*' ! -name '.*' | sort); do
	# ignore containing directory
	if [ "$1" != "$dotfile" ]; then
		name="${dotfile##*/}"
		dest="$HOME/.$name"

		backup "$dest"

		echo linking "$dest"
		ln -s "$dotfile" "$dest"
	fi
    done
}

backup "$HOME/.ellipsis"
git_clone "https://github.com/zeekay/ellipsis" "$HOME/.ellipsis"

trap "exit 0" SIGINT

if [ -z "$MODULES" ]; then
    echo
    echo "Available modules: "
    echo "    files"
    echo "    emacs"
    echo "    irssi"
    echo "    vim"
    echo "    xmonad"
    echo "    zsh"

    echo
    echo "List modules to install (by name or 'github:repo/user') or enter to exit:"
    read modules </dev/tty
else
    modules="$MODULES"
fi

mkdir -p "$HOME/.ellipsis/modules"
for module in $modules; do
    echo

    case $module in
        github:*)
            user=$(echo "$module" | cut -d ':' -f 2 | cut -d '/' -f 1)
            module=$(echo "$module" | cut -d ':' -f 2 | cut -d '/' -f 2)
            module_path="$HOME/.ellipsis/modules/$module"
            git_clone "https://github.com/$user/$module" "$module_path"
        ;;
        *)
            module_path="$HOME/.ellipsis/modules/$module"
            git_clone "https://github.com/zeekay/dot-$module" "$module_path"
        ;;
    esac

    . "$module_path/.ellipsis/install"
done
