#!/bin/sh
# Script to automatically setup dotfile
basedir="$( cd -P "$( dirname "$0" )" && pwd )"

for dotfile in $basedir/dot.*; do
    name="$(basename $dotfile)"
    dotname="${name:3}"
    dest=~/"$dotname"

    # erasing existing dotfiles
    if [ "$1" == "-f" ]; then
        rm -rf "$dest"
    fi

    echo linking $dotname
    ln -s "$dotfile" "$dest"
done

echo "list any additional external repos to install or enter to exit"
read external_repos

for repo in $external_repos; do
    echo -n "install dot files from $repo? (y/n) "
    read input
    if [ "$input" == "y" ]; then
        if [ "${repo[1,3]}" == "hg+" ]; then
            name=`echo ${repo:3} | rev | cut -d "/" -f1 | rev`
            hg clone ${repo:3} $basedir/$name
        elif [ "${repo[1,4]}" == "git+" ]; then
            name=`echo ${repo:4} | rev | cut -d "/" -f1 | rev`
            git clone ${repo:4} $basedir/$name
        else
            name=$repo
            hg clone https://bitbucket.org/zeekay/dot-$repo $basedir/dot-$repo
        fi
        repo_basedir=$basedir/$name
        . $real_basedir/setup.sh
    fi
done
