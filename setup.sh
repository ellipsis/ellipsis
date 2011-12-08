#!/bin/sh

# Script to automatically setup dotfiles

basedir="$( cd -P "$( dirname "$0" )" && pwd )"

trap "exit 0" SIGINT

echo "linking dot files"

for dotfile in `find $basedir -maxdepth 1 -name '*' \
    -a ! -name 'setup.sh' \
    -a ! -name 'scripts' \
    -a ! -name '.*' \
    -a ! -name 'dot-*' | sort`; do

    name="`basename $dotfile`"
    dest="$HOME/.$name"

    # erasing existing dotfiles
    if [ "$1" = "-f" ]; then
        echo "removing $dest"
        rm -rf "$dest"
    fi

    if [ -f "$dest" ] || [ -d "$dest" ]; then
        echo "$name already exists"
    else
        echo "linking $name"
        ln -s "$dotfile" "$dest"
    fi
done

echo
echo "list any additional external repos to install or enter to exit"
read external_repos

dotfiles_dir=$basedir
for repo in $external_repos; do
    # reset basedir
    basedir=$dotfiles_dir
    echo
    echo -n "clone and install $repo? (y/n) "
    read input
    if [ "$input" = "y" ]; then
        case $repo in
            hg+*)
                repo=`echo $repo | cut -c 4-`
                name=`echo $repo | rev | cut -d "/" -f1 | rev`
                # trim dot- from beginning of repo name
                [ "`echo $name | cut -c1-4`" = "dot-" ] && name=`echo $name | cut -c5-`
                hg clone $repo $basedir/$name
            ;;
            git+*)
                repo=`echo $repo | cut -c 5-`
                name=`echo $repo | rev | cut -d "/" -f1 | rev | cut -c5-`
                # trim dot- from beginning of repo name
                [ "`echo $name | cut -c1-4`" = "dot-" ] && name=`echo $name | cut -c5-`
                git clone $repo $basedir/$name
            ;;
            *)
                name=$repo
                # trim dot- from beginning of repo name
                [ "`echo $name | cut -c1-4`" = "dot-" ] && name=`echo $name | cut -c5-`
                hg clone https://bitbucket.org/zeekay/dot-$name $basedir/$name
            ;;
        esac
        repo_basedir=$basedir/$name
        . $repo_basedir/setup.sh
    fi
done
