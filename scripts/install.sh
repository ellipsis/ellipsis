#!/usr/bin/env bash
#
# scripts/install.sh
# Installer for ellipsis (http://ellipsis.sh).

# Ensure dependencies are installed.
deps=(bash curl git)

for dep in ${deps[*]}; do
    hash $dep 2>/dev/null || { echo >&2 "ellipsis requires $dep to be installed."; exit 1; }
done

# Create temp dir.
tmp_dir=$(mktemp -d ${TMPDIR:-tmp}-XXXXXX)

# Clone ellipsis into $tmp_dir.
git clone --depth 1 git://github.com/zeekay/ellipsis.git $tmp_dir/ellipsis

# Initialize ellipsis.
source $tmp_dir/ellipsis/src/init.sh

# Load modules.
load ellipsis
load epmi
load git
load package
load utils

# Backup existing ~/.ellipsis if necessary and  move project into place.
ellipsis.backup $HOME/.ellipsis
mv $tmp_dir/ellipsis $HOME/.ellipsis

# Clean up (only necessary on cygwin, really).
rm -rf $tmp_dir

# Backwards compatability, originally referred to packages as modules.
PACKAGES="${PACKAGES:-$MODULES}"

if [ -z "$PACKAGES" ]; then
    # List available packages.
    epmi.list_packages

    # List default packages for this platform.
    if [ "$(utils.platform)" = "darwin" ]; then
        default="zeekay/dot-files zeekay/dot-vim zeekay/dot-zsh zeekay/dot-alfred zeekay/dot-iterm2"
    else
        default="zeekay/dot-files zeekay/dot-vim zeekay/dot-zsh"
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
