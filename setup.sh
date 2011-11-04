#!/bin/sh
# Script to automatically setup dotfile
basedir="$( cd -P "$( dirname "$0" )" && pwd )"

echo "linking dot files"
for dotfile in $basedir/dot.*; do
    name="`basename $dotfile`"
    dotname="`echo $name | cut -c4-`"
    dest="$HOME/$dotname"

    # erasing existing dotfiles
    if [ "$1" = "-f" ]; then
        echo "removing $dest"
        rm -rf "$dest"
    fi

    if [ -f "$dest" ] || [ -d "$dest" ]; then
        echo "$dotname already exists"
    else
        echo "linking $dotname"
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
    echo -n "install dot files from $repo? (y/n) "
    read input
    if [ "$input" = "y" ]; then
        case $repo in
            hg+*)
                repo=`echo $repo | cut -c 3-`
                name=`echo $repo  rev | cut -d "/" -f1 | rev`
                hg clone $repo $basedir/$name
            ;;
            git+*)
                repo=`echo $repo | cut -c 4-`
                name=`echo $repo | rev | cut -d "/" -f1 | rev`
                git clone $repo $basedir/$name
            ;;
            *)
                name=dot-$repo
                hg clone https://bitbucket.org/zeekay/$name $basedir/$name
            ;;
        esac
        repo_basedir=$basedir/$name
        . $repo_basedir/setup.sh
    fi
done
