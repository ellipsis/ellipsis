# ellipsis.bash
#
# Core ellipsis interface.

load fs
load git
load pkg
load utils
load log

# List all installed packages.
ellipsis.list_packages() {
    if ! fs.folder_empty $ELLIPSIS_PACKAGES; then
        echo $ELLIPSIS_PACKAGES/*
    fi
}

# Run commands across all packages.
ellipsis.each() {
    # execute command for ellipsis first
    pkg.init $ELLIPSIS_PATH
    "$@"
    pkg.del

    # loop over packages, excecuting command
    for pkg in $(ellipsis.list_packages); do
        pkg.init "$pkg"
        "$@"
        pkg.del
    done
}

# Installs new ellipsis package, using install hook if one exists. If no hook is
# defined, all files are symlinked into ELLIPSIS_HOME using `fs.link_files`.
ellipsis.install() {
    if [ $# -lt 1 ]; then
        log.fail "No package specified for install"
        exit 1
    fi

    for package in "$@"; do
        # split branch from package name (if possible)
        parts=($(pkg.split_name "$package"))
        PKG_RAW="${parts[0]}"
        PKG_BRANCH="${parts[1]}"

        if [ -e "$PKG_RAW" ]; then
            PKG_URL="$PKG_RAW"
            PKG_NAME="$(pkg.name_from_url $PKG_URL)"
        else
            case "$PKG_RAW" in
                ssh://git)
                    # Set correct url by restoring first '@' coming from
                    # 'ssh://git@...'
                    PKG_URL="${parts[0]}@${parts[1]}"
                    PKG_NAME="$(pkg.name_from_url $PKG_URL)"
                    # Set correct branch
                    PKG_BRANCH="${parts[2]}"
                ;;
                # 'ssh:*' still included because user could be handled in
                # ~/.ssh/config
                http:*|https:*|git:*|ssh:*)
                    PKG_URL="$PKG_RAW"
                    PKG_NAME="$(pkg.name_from_url $PKG_URL)"
                ;;
                */*)
                    PKG_USER="$(pkg.user_from_shorthand $PKG_RAW)"
                    PKG_NAME="$(pkg.name_from_shorthand $PKG_RAW)"
                    PKG_URL="$ELLIPSIS_PROTO://github.com/$PKG_USER/dot-$(pkg.name_stripped $PKG_NAME)"
                ;;
                # Easy extension installation
                ellipsis-*)
                    PKG_NAME="$PKG_RAW"
                    PKG_URL="$ELLIPSIS_PROTO://github.com/ellipsis/$PKG_NAME"
                ;;
                *)
                    PKG_NAME="$PKG_RAW"
                    PKG_URL="$ELLIPSIS_PROTO://github.com/$ELLIPSIS_USER/dot-$(pkg.name_stripped $PKG_NAME)"
                ;;
            esac
        fi

        # strip leading dot- from name as a convenience
        PKG_NAME=$(pkg.name_stripped $PKG_NAME)
        PKG_PATH="$(pkg.path_from_name $PKG_NAME)"

        if [ -z "$PKG_BRANCH" ]; then
            git.clone "$PKG_URL" "$PKG_PATH"
        else
            git.clone "$PKG_URL" "$PKG_PATH" --branch "$PKG_BRANCH"
        fi

        pkg.init "$PKG_PATH"
        pkg.run_hook "link"
        pkg.run_hook "install"
        pkg.del
    done
}

# Uninstall package, using uninstall hook if one exists. If no hook is
# defined, all symlinked files in ELLIPSIS_HOME are removed and package is rm -rf'd.
ellipsis.uninstall() {
    if [ $# -ne 1 ]; then
        log.fail "No package specified for uninstall"
        exit 1
    fi

    pkg.init "$1"
    pkg.run_hook "uninstall"
    pkg.del
}

# Re-link unlinked packages.
ellipsis.link() {
    if [ $# -ne 1 ]; then
        log.fail "No package specified to link"
        exit 1
    fi

    pkg.init "$1"
    pkg.run_hook "link"
    pkg.del
}

# Unlink package, using unlink hooks, using unlink hook if one exists. If no
# hook is defined, all symlinked files in ELLIPSIS_HOME are removed.
ellipsis.unlink() {
    if [ $# -ne 1 ]; then
        log.fail "No package specified to unlink"
        exit 1
    fi

    pkg.init "$1"
    pkg.run_hook "unlink"
    pkg.del
}

# List installed packages.
ellipsis.installed() {
    if utils.cmd_exists column; then
        ellipsis.each pkg.run_hook "installed" | column -t -s $'\t'
    else
        ellipsis.each pkg.run_hook "installed"
    fi
}

# List(s) package git status.
ellipsis.status() {
    if [ $# -eq 1 ]; then
        pkg.init "$1"
        pkg.run_hook "status"
        pkg.del
    else
        ellipsis.each pkg.run_hook "status"
    fi
}

# Updates package(s) with git pull.
ellipsis.pull() {
    if [ $# -eq 1 ]; then
        if [[ "$1" =~ ^[Ee]llipsis$ ]]; then
            pkg.init $ELLIPSIS_PATH
        else
            pkg.init "$1"
        fi

        pkg.run_hook "pull"
        pkg.del
    else
        ellipsis.each pkg.run_hook "pull"
    fi
}

# Push updated package(s) with git push.
ellipsis.push() {
    if [ $# -eq 1 ]; then
        pkg.init "$1"
        pkg.run_hook "push"
        pkg.del
    else
        ellipsis.each pkg.run_hook "push"
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
# $ELLIPSIS_USER/$PKG_NAME ellipsis package

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

# pkg.installed() {
#     git.status
# }
#
# pkg.status() {
#     git.diffstat
# }
EOF

    # Generate README.md for package.
    cat > $PKG_PATH/README.md <<EOF
# $ELLIPSIS_USER/$PKG_NAME
Just a bunch of dotfiles.

## Install
Clone and symlink or install with [ellipsis][ellipsis]:

$_FENCE
$_PROMPT ellipsis install $ELLIPSIS_USER/$PKG_NAME
$_FENCE

[ellipsis]: http://ellipsis.sh
EOF

    cd $PKG_PATH
    git init
    git add README.md ellipsis.sh
    git commit -m "Initial commit"
    echo new package created at $(path.relative_to_home $PKG_PATH)
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

# List all symlinks (slightly optimized over calling pkg.list_symlinks for each
# package.
ellipsis._list_symlink_mappings() {
    for file in $(fs.list_symlinks); do
        local link="$(readlink $file)"
        if [[ "$link" == $ELLIPSIS_PATH* ]]; then
            echo "$(path.relative_to_packages $link) -> $(path.relative_to_home $file)";
        fi
    done
}

# List all symlinks, or just symlinks for a given package
ellipsis.links() {
    if [ $# -eq 1 ]; then
        pkg.init "$1"
        pkg.run_hook "links"
        pkg.del
    else
        if utils.cmd_exists column; then
            ellipsis._list_symlink_mappings | sort | column -t
        else
            ellipsis._list_symlink_mappings | sort
        fi
    fi
}

ellipsis._list_broken_symlink_mappings() {
    for file in $(fs.list_broken_symlinks $ELLIPSIS_HOME); do
        echo "$(path.relative_to_packages $(readlink $file)) -> $(path.relative_to_home $file)";
    done
}

# List broken symlinks in ELLIPSIS_HOME
ellipsis.broken() {
    if utils.cmd_exists column; then
        ellipsis._list_broken_symlink_mappings | sort | column -t
    else
        ellipsis._list_broken_symlink_mappings | sort
    fi
}

# List broken symlinks in ELLIPSIS_HOME
ellipsis.clean() {
    for file in $(fs.list_broken_symlinks $ELLIPSIS_HOME); do
        rm $file
    done
}

# Re-link unlinked packages.
ellipsis.add() {
    if [ $# -lt 2 ]; then
        log.fail "Usage: ellipsis add <package> <dotfile>"
        exit 1
    fi

    for file in "${@:2}"; do
        # Important to get absolute path of each file as we'll be changing
        # directory when hook is run.
        local file="$(path.abs_path $file)"
        pkg.init "$1"
        pkg.run_hook "add" "$file"
        pkg.del
    done
}
