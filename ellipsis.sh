#!/bin/sh

backup() {
    original="$1"
    backup="$original.bak"
    name="`basename $original`"

    if [ -e "$original" ]; then
        echo "Backing up ~/$name"

        if [ -e "$backup" ]; then
            n=1
            while [ -e "$backup.$n" ]; do
                (( n ++ ))
            done
            backup="$backup.$n"
        fi
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
