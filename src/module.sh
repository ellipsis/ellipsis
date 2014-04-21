#!/usr/bin/env bash
#
# ellipsis module interface

## public functions

mod_hooks=(install uninstall pull push status list)

# initialize a module and it's hooks
mod.init() {
    mod_path=${1:-$mod_path}
    mod_name=${2:-${module##*/}}

    # if ellipsis.sh exists, source it
    if [ -f "$mod_path/ellipsis.sh" ]; then
        source "$mod_path/ellipsis.sh"
    fi
}

# find module's symlinks
mod.find_symlinks() {
    local mod_name=${1:-$mod_name}
    utils.find_symlinks | grep ellipsis/modules/$mod_name
}

# run hook or command inside mod_path
mod.run() {
    local cmd="$1"
    local cwd="$(pwd)"
    local module_path=${2:-$module_path}

    # change to module dir
    cd "$mod_path"

    # run hook or command
    case $cmd in
        mod.*)
            mod.run_hook $cmd
            ;;
        *)
            $cmd
            ;;
    esac

    # return after running command
    cd "$cwd"
}

# run hook if it's defined, otherwise use default implementation
mod.run_hook() {
    local hook=$1
    if utils.cmd_exists $hook; then
        $hook
    else
        case $hook in
            mod.install)
                ellipsis.link_files $mod_path
                ;;
            mod.uninstall)
                local symlinks=(mod.find_symlinks)

                for symlink in ${symlinks[@]}; do
                    rm $symlink
                done
                ;;
            mod.pull)
                mod.run git.pull
                ;;
            mod.push)
                mod.run git.push
                ;;
            mod.list)
                mod.run git.list
                ;;
            mod.status)
                mod.run git.status
                ;;
        esac
    fi
}

# unset global modules
mod._unset_vars() {
    unset mod_name
    unset mod_path
}

# unset any hooks that might have been defined by module
mod._unset_hooks() {
    for hook in ${mod_hooks[@]}; do
        unset -f mod.$hook
    done
}

# clear globals, hooks
mod.del() {
    mod._unset_vars
    mod._unset_hooks
}
