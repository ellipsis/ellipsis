#!/bin/sh
# Script to automatically setup dotfile
basedir="$( cd -P "$( dirname "$0" )" && pwd )"

echo "linking dot files"
for dotfile in $basedir/dot.*; do
    name="$(basename $dotfile)"
    dotname="${name:3}"
    dest=~/"$dotname"

    # erasing existing dotfiles
    if [ "$1" == "-f" ]; then
        rm -rf "$dest"
    fi

    if [ -z "$dest" ]; then
        echo linking $dotname
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
    echo
    if [ "$input" == "y" ]; then
        if [ "${repo[1,3]}" == "hg+" ]; then
            name=`echo ${repo:3} | rev | cut -d "/" -f1 | rev`
            hg clone ${repo:3} $basedir/$name
        elif [ "${repo[1,4]}" == "git+" ]; then
            name=`echo ${repo:4} | rev | cut -d "/" -f1 | rev`
            git clone ${repo:4} $basedir/$name
        else
            name=dot-$repo
            hg clone https://bitbucket.org/zeekay/$name $basedir/$name
        fi
        repo_basedir=$basedir/$name
        . $repo_basedir/setup.sh
    fi
done
