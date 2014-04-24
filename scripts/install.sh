#!/usr/bin/env bash
#
# Installer for ellipsis (http://ellipsis.sh)

ELLIPSIS_USER="${ELLIPSIS_USER:-zeekay}"
ELLIPSIS_REPO="${ELLIPSIS_REPO:-https://github.com/$ELLIPSIS_USER/ellipsis}"
ELLIPSIS_URL="${ELLIPSIS_URL:-https://raw.githubusercontent.com/$ELLIPSIS_USER/ellipsis/master}"

# ensure dependencies are installed
deps=(bash curl git)

for dep in ${deps[*]}; do
    hash $dep 2>/dev/null || { echo >&2 "ellipsis requires $dep to be installed."; exit 1; }
done

# create temp dir
tmp_dir=$(mktemp -d ${TMPDIR:-tmp}-XXXXXX)

# download necessary bits
curl -sL "$ELLIPSIS_URL/src/git.sh" > $tmp_dir/git.sh
curl -sL "$ELLIPSIS_URL/src/utils.sh" > $tmp_dir/utils.sh
curl -sL "$ELLIPSIS_URL/src/ellipsis.sh" > $tmp_dir/ellipsis.sh

# source ellipsis lib files
source $tmp_dir/git.sh
source $tmp_dir/utils.sh
source $tmp_dir/ellipsis.sh

# clean up (only necessary on cygwin, really)
rm -rf $tmp_dir

# backup existing copy
ellipsis.backup ~/.ellipsis

# Download latest copy of ellipsis
git.clone "$ELLIPSIS_REPO" ~/.ellipsis

if [ -z "$PACKAGES" ]; then
    # list available packages
    ellipsis.available

    # list default packages
    if [ "$(utils.platform)" = "darwin" ]; then
        default="files vim zsh alfred iterm2"
    else
        default="files vim zsh"
    fi

    echo "default: $default"

    # allow user to override defaults
    read packages < /dev/tty
    packages="${packages:-$default}"
else
    # user already provided packages list to install
    packages="$PACKAGES"
fi

# install selected packages.
for package in ${packages[*]}; do
    ellipsis.install $package
done

echo
echo 'Note: export PATH=~/.ellipsis/bin:$PATH to add ellipsis to your $PATH      '
echo
echo '   _    _    _                                                             '
echo '  /\_\ /\_\ /\_\                                                           '
echo '  \/_/ \/_/ \/_/                         …because $HOME is where the <3 is!'
echo
