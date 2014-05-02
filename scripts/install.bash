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

# Save reference to specified ELLIPSIS_PATH (if any) otherwise final
# destination: $HOME/.ellipsis.
FINAL_ELLIPSIS_PATH=${ELLIPSIS_PATH:-$HOME/.ellipsis}

# Temporarily set ellipsis PATH so we can load other files.
ELLIPSIS_PATH="$tmp_dir/ellipsis"

# Initialize ellipsis.
source $tmp_dir/ellipsis/src/init.bash

# Load modules.
load ellipsis
load fs
load os
load registry
load utils

ELLIPSIS_PATH="$FINAL_ELLIPSIS_PATH"

# Backup existing ~/.ellipsis if necessary and  move project into place.
fs.backup $ELLIPSIS_PATH
mv $tmp_dir/ellipsis $ELLIPSIS_PATH

# Clean up (only necessary on cygwin, really).
rm -rf $tmp_dir

# Backwards compatability, originally referred to packages as modules.
PACKAGES="${PACKAGES:-$MODULES}"

if [ "$PACKAGES" ]; then
    for pkg in ${PACKAGES[*]}; do
        echo
        echo -e "\033[1minstalling $pkg\033[0m"
        ellipsis.install "$pkg"
    done
fi

echo '...done!'
echo '   _    _    _'
echo '  /\_\ /\_\ /\_\'
echo '  \/_/ \/_/ \/_/                         …because $HOME is where the <3 is!'
echo
echo 'Make sure to add `export PATH=~/.ellipsis/bin:$PATH` to your bashrc or zshrc.'
echo
echo 'Run `ellipsis install <package>` to install a new package.'
echo 'Run `ellipsis search <query>` to search for packages to install.'
echo 'Run `ellipsis help` for additional options.'

if [[ -z "$PACKAGES" ]]; then
    if [ $(os.platform) = osx ]; then
        PACKAGES="zeekay/files zeekay/vim zeekay/zsh zeekay/alfred zeekay/iterm2"
    else
        PACKAGES="zeekay/files zeekay/vim zeekay/zsh"
    fi

    echo
    echo "Recommended packages: $PACKAGES"
fi
