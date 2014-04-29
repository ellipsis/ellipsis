#!/usr/bin/env bash
#
# ellipsis.sh
# Core ellipsis interface.

# Initialize ourselves if we haven't yet.
if [[ $ELLIPSIS_INIT -ne 1 ]]; then
    source "$(dirname "${BASH_SOURCE[0]}")/init.sh"
fi

load fs
load git
load pkg
load utils

# List all installed packages.
ellipsis.list_packages() {
    if ! fs.folder_empty $ELLIPSIS_PATH/packages; then
        echo $ELLIPSIS_PATH/packages/*
    fi
}

# Run commands across all packages.
ellipsis.each() {
    # execute command for ellipsis first
    pkg.init $ELLIPSIS_PATH
    pkg.run "$@"
    pkg.del

    # loop over packages, excecuting command
    for pkg in $(ellipsis.list_packages); do
        pkg.init "$pkg"
        pkg.run "$@"
        pkg.del
    done
}

# Installs new ellipsis package, using install hook if one exists. If no hook is
# defined, all files are symlinked into ELLIPSIS_HOME using `fs.link_files`.
ellipsis.install() {
    case "$1" in
        http:*|https:*|git:*|ssh:*)
            PKG_NAME="$(echo $1 | rev | cut -d '/' -f 1 | rev)"
            PKG_PATH="$(pkg.name_to_path $PKG_NAME)"
            PKG_URL="$1"
        ;;
        */*)
            PKG_USER=$(echo $1 | cut -d '/' -f1)
            PKG_NAME=$(echo $1 | cut -d '/' -f2)
            PKG_PATH="$(pkg.name_to_path $PKG_NAME)"
            PKG_URL="$ELLIPSIS_PROTO://github.com/$PKG_USER/$PKG_NAME"
        ;;
        *)
            PKG_NAME="$1"
            PKG_PATH="$(pkg.name_to_path $PKG_NAME)"
            PKG_URL="$ELLIPSIS_PROTO://github.com/$ELLIPSIS_USER/$PKG_NAME"
        ;;
    esac

    git.clone "$PKG_URL" "$PKG_PATH"

    pkg.init "$PKG_PATH"
    pkg.run pkg.install
    pkg.del
}

# Uninstall package, using uninstall hook if one exists. If no hook is
# defined, all symlinked files in ELLIPSIS_HOME are removed and package is rm -rf'd.
ellipsis.uninstall() {
    pkg.init "$1"
    pkg.run pkg.uninstall
    pkg.del
}

# Unlink package, using unlink hooks, using unlink hook if one exists. If no
# hook is defined, all symlinked files in ELLIPSIS_HOME are removed.
ellipsis.unlink() {
    pkg.init "$1"
    pkg.run pkg.unlink
    pkg.del
}

# List installed packages.
ellipsis.list() {
    if utils.cmd_exists column; then
        ellipsis.each pkg.list | column -t -s $'\t'
    else
        ellipsis.each pkg.list
    fi
}

# List(s) package git status.
ellipsis.status() {
    if [ $# -eq 1 ]; then
        pkg.init "$1"
        pkg.run pkg.status
        pkg.del
    else
        ellipsis.each pkg.status
    fi
}

# Updates package(s) with git pull.
ellipsis.pull() {
    if [ $# -eq 1 ]; then
        pkg.init "$1"
        pkg.run pkg.pull
        pkg.del
    else
        ellipsis.each pkg.pull
    fi
}

# Push updated package(s) with git push.
ellipsis.push() {
    if [ $# -eq 1 ]; then
        pkg.init "$1"
        pkg.run pkg.push
        pkg.del
    else
        ellipsis.each pkg.push
    fi
}

# Scaffold a new package.
ellipsis.new() {
    # If no-argument is passed, use cwd as package path.
    if [ $# -eq 1 ]; then
        pkg.init_globals "$1"
    else
        pkg.init_globals "$(pwd)"
    fi

    # Create package dir if necessary.
    mkdir -p $PKG_PATH

    # If path is not empty, ensure they are serious.
    if ! fs.folder_empty $PKG_PATH; then
        utils.prompt "destination is not empty, continue? [y/n]" || exit 1
    fi

    # Template variables.
    local _PKG_PATH='$PKG_PATH'
    local _PROMPT='$'
    local _FENCE=\`\`\`

    # Generate ellipsis.sh for package.
    cat > $PKG_PATH/ellipsis.sh <<EOF
#!/usr/bin/env bash
#
# $PKG_NAME ellipsis package

# The following hooks can be defined to customize behavior of your package:
# pkg.install() {
#     fs.link_files $_PKG_PATH
# }

# pkg.push() {
#     git.push
# }

# pkg.pull() {
#     git.pull
# }

# pkg.status() {
#     git.status
# }
EOF

    # Generate README.md for package.
    cat > $PKG_PATH/README.md <<EOF
# $PKG_NAME
Just a bunch of dotfiles.

## Install
Clone and symlink or install with [ellipsis][ellipsis]:

$_FENCE
$_PROMPT ellipsis install $PKG_NAME
$_FENCE

[ellipsis]: http://ellipsis.sh
EOF

    cd $PKG_PATH
    git init
    git add README.md ellipsis.sh
    git commit -m "Initial commit"
    echo new package created at ${path.relative_path $PKG_PATH}
}

# Edit ellipsis.sh for package, or open ellipsis dir in $EDITOR.
ellipsis.edit() {
    if [ $# -eq 1 ]; then
        # Edit package's ellipsis.sh file.
        pkg.init "$1"
        $EDITOR $PKG_PATH/ellipsis.sh
    else
        # Open ellipsis dir in editor.
        $EDITOR $ELLIPSIS_PATH
    fi
}

# List all symlinks, or just symlinks for a given package
ellipsis.symlinks() {
    if [ $# -eq 1 ]; then
        pkg.init "$1"
        pkg.run pkg.symlinks
        pkg.del
    else
        if utils.cmd_exists column; then
            ellipsis.list_symlink_mappings | sort | column -t
        else
            ellipsis.list_symlink_mappings | sort
        fi
    fi
}

# List broken symlinks in ELLIPSIS_HOME
ellipsis.broken() {
    for file in $(find -L $ELLIPSIS_HOME -maxdepth 1 -type l); do
        echo "$(utils.strip_packages_dir $(readlink $file)) -> $(path.relative_path $file)";
    done
}

# List broken symlinks in ELLIPSIS_HOME
ellipsis.clean() {
    find -L $ELLIPSIS_HOME -maxdepth 1 -type l| xargs rm
}

