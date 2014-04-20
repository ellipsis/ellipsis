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
tmp_dir=$(mktemp -d) && cd $tmp_dir
echo in $tmp_dir

# Download lib components
curl -L "$ELLIPSIS_URL/src/git.sh" > git.sh
curl -L "$ELLIPSIS_URL/src/ellipsis.sh" > ellipsis.sh

# source lib files
source git.sh
source ellipsis.sh

ellipsis.backup ~/.ellipsis

# Download latest copy of ellipsis
git.clone "$ELLIPSIS_REPO" ~/.ellipsis

if [ -z "$MODULES" ]; then
    # list available modules
    ellipsis.list

    # list default modules
    if [ "$(ellipsis.platform)" = "darwin" ]; then
        default="files vim zsh alfred iterm2"
    else
        default="files vim zsh"
    fi

    echo "default: $default"

    # allow user to override defaults
    read modules
    modules="${modules:-$default}"
else
    # user already provided modules list to install
    modules="$MODULES"
fi

for module in ${modules[*]}; do
    ellipsis.install $module
done
