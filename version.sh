#!/bin/sh

basedir="$( cd -P "$( dirname "$0" )" && pwd )"

echo dot-files:`hg id -n $basedir`

for dir in $basedir/dot-*; do
    name=`echo $dir | rev | cut -d "/" -f1 | rev`
    echo ${name:4}:`hg id -n $dir`
done
