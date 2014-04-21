#!/usr/bin/env bash
#
# ellipsis module interface

mod_hooks=(install uninstall symlinks pull push status list)

# mod_name -> mod_path
mod.name_to_path() {
    echo "$HOME/.ellipsis/modules/$1"
}

# mod path -> name
mod.path_to_name() {
    echo "${1##*/}"
}

# initialize a module and it's hooks
mod.init() {
    # we can be passed either a name or path, paths are assumed to be absolute,
    # and should have a slash in them.
    if utils.hash_slash $1; then
        mod_path="$1"
        mod_name="$(mod.path_to_name $1)"
    else
        mod_name="$1"
        mod_path="$(mod.name_to_path $1)"
    fi

    # source ellipsis.sh if it exists to initialize module hooks
    if [ -f "$mod_path/ellipsis.sh" ]; then
        source "$mod_path/ellipsis.sh"
    fi
}

# find module's symlinks
mod.find_symlinks() {
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
                for symlink in $(mod.find_symlinks); do
                    rm $symlink
                done
                ;;
            mod.symlinks)
                mod.find_symlinks
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
