#!/usr/bin/env bash
#
# Installer for ellipsis (http://ellipsis.sh)

ELLIPSIS_USER="${ELLIPSIS_USER:-zeekay}"
ELLIPSIS_REPO="${ELLIPSIS_REPO:-https://github.com/$ELLIPSIS_USER/ellipsis}"
ELLIPSIS_URL="${ELLIPSIS_URL:-https://raw.githubusercontent.com/$ELLIPSIS_USER/ellipsis/master}"

# Ensure dependencies are installed.
deps=(bash curl git)

for dep in ${deps[*]}; do
    hash $dep 2>/dev/null || { echo >&2 "ellipsis requires $dep to be installed."; exit 1; }
done

# Create temp directory
tmp_dir=$(mktemp -d ${TMPDIR:-tmp}-XXXXXX)

# Download lib components
curl -sL "$ELLIPSIS_URL/src/git.sh" > $tmp_dir/git.sh
curl -sL "$ELLIPSIS_URL/src/utils.sh" > $tmp_dir/utils.sh
curl -sL "$ELLIPSIS_URL/src/ellipsis.sh" > $tmp_dir/ellipsis.sh

# source ellipsis lib files
source $tmp_dir/git.sh
source $tmp_dir/utils.sh
source $tmp_dir/ellipsis.sh

ellipsis.backup ~/.ellipsis

# Download latest copy of ellipsis
git.clone "$ELLIPSIS_REPO" ~/.ellipsis

if [ -z "$MODULES" ]; then
    # list available modules
    ellipsis.available

    # list default modules
    if [ "$(ellipsis.platform)" = "darwin" ]; then
        default="files vim zsh alfred iterm2"
    else
        default="files vim zsh"
    fi

    echo "default: $default"

    # allow user to override defaults
    read modules < /dev/tty
    modules="${modules:-$default}"
else
    # user already provided modules list to install
    modules="$MODULES"
fi

for module in ${modules[*]}; do
    ellipsis.install $module
done

echo
echo 'Note: export PATH=~/.ellipsis/bin:$PATH to add ellipsis to your $PATH      '
echo
echo '   _    _    _                                                             '
echo '  /\_\ /\_\ /\_\                                                           '
echo '  \/_/ \/_/ \/_/                         …because $HOME is where the <3 is!'
echo
