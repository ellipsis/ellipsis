#!/bin/sh

backup() {
    original="$1"
    backup="$original.bak"
    name="`basename $original`"

    if [ "`find -L $original -maxdepth 0 -type l 2>/dev/null`" != "" ]; then
        broken="`readlink $original`"

        if [ "`echo $broken | grep .ellipsis`" != "" ]; then
            rm $original
        else
            echo "rm ~/$name (broken link to $broken)"
            rm $original
        fi

        return
    fi

    if [ -e "$original" ]; then
        if [ -e "$backup" ]; then
            n=1
            while [ -e "$backup.$n" ]; do
                (( n ++ ))
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
    curl -s "https://raw.github.com/zeekay/$1/master/install.sh" > $1-install-$$.sh
    ELLIPSIS_INSTALL=1 sh $1-install-$$.sh
    rm $1-install-$$.sh
}

link_files() {
    for dotfile in `find "$1" -maxdepth 1 -name '*' ! -name '.*' | sort`; do
	# ignore containing directory
	if [ "$1" != "$dotfile" ]; then
		name="`basename $dotfile`"
		dest="$HOME/.$name"

		backup "$dest"

		echo linking "$dest"
		ln -s "$dotfile" "$dest"
	fi
    done
}

link_file() {
    name="`basename $1`"

    if [ -z "$2" ]; then
        dest="$HOME/.$name"
    else
        dest="$2"
    fi

    backup "$dest"

	echo linking "$dest"
    ln -s "$1" "$dest"
}

backup $HOME/.ellipsis
git_clone "https://github.com/zeekay/ellipsis" "$HOME/.ellipsis"

trap "exit 0" SIGINT

link_files "$HOME/.ellipsis/common"

case `uname | tr '[:upper:]' '[:lower:]'` in
    darwin)
        link_files "$HOME/.ellipsis/platform/osx"
    ;;
    freebsd)
        link_files "$HOME/.ellipsis/platform/freebsd"
    ;;
    linux)
        link_files "$HOME/.ellipsis/platform/linux"
    ;;
    cygwin*)
        link_files "$HOME/.ellipsis/platform/cygwin"
    ;;
esac

echo
echo "Available modules: "
curl --silent https://api.github.com/users/zeekay/repos \
    | grep '"name":' \
    | cut -d '"' -f 4 \
    | grep dot- \
    | sed -e 's/dot-//'

echo
echo "List modules to install (by name or 'github:repo/user') or enter to exit"
read modules </dev/tty

mkdir -p "$HOME/.ellipsis/modules"
for module in $modules; do
    echo

    case $module in
        github:*)
            user=`echo $module cut -d ':' -f 2 | cut -d '/' -f 1`
            module=`echo $module cut -d ':' -f 2 | cut -d '/' -f 2`
            module_path=$HOME/.ellipsis/modules/$module
            git_clone "https://github.com/$user/$module" $module_path
        ;;
        *)
            module_path=$HOME/.ellipsis/modules/$module
            git_clone "https://github.com/zeekay/dot-$module" $module_path
        ;;
    esac

    . $module_path/.ellipsis-module/install
done
