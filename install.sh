#!/bin/sh

ellipsis="`pwd`/ellipsis-$$.sh"
curl -s "https://raw.github.com/zeekay/ellipsis/master/ellipsis.sh" > $ellipsis
. $ellipsis
rm $ellipsis

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
