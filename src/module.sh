#!/usr/bin/env bash
#
# ellipsis module interface

mod_hooks=(install uninstall symlinks pull push status list)

# mod_name -> mod_path
mod.name_to_path() {
    local name="$1"

    echo "$HOME/.ellipsis/modules/$name"
}

# mod path -> name
mod.path_to_name() {
    local path="$1"

    echo $(utils.strip_leading_dot "${path##*/}")
}

# initialize a module and it's hooks
mod.init() {
    local name_or_path="$1"

    # we can be passed either a name or path, paths are assumed to be absolute,
    # and should have a slash in them.
    if utils.hash_slash $name_or_path; then
        mod_path="$name_or_path"
        mod_name="$(mod.path_to_name $mod_path)"
    else
        mod_name="$name_or_path"
        mod_path="$(mod.name_to_path $mod_name)"
    fi

    # source ellipsis.sh if it exists to initialize module hooks
    if [ -f "$mod_path/ellipsis.sh" ]; then
        source "$mod_path/ellipsis.sh"
    fi
}

# find module's symlinks
mod.find_symlinks() {
    local mod_name=${1:-$mod_name}

    echo -e "\033[1m$mod_name symlinks\033[0m" | sed 's/\-e //'
    utils.find_symlinks | grep ellipsis/modules/$mod_name
}

# run hook or command inside mod_path
mod.run() {
    local cmd="$1"
    local cwd="$(pwd)"

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

# clear globals, hooks
mod.del() {
    mod._unset_vars
    mod._unset_hooks
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
