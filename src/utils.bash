# utils.bash
#
# Utility functions used by ellipsis.

# check if a command or function exists
utils.cmd_exists() {
    hash "$1" &> /dev/null
}

# prompt with message and return true if yes/YES, otherwise false
utils.prompt() {
    read -r -p "$1 " answer
    case $answer in
        y*|Y*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Run web-based installers
utils.run_installer() {
    # save reference to current dir
    local cwd=$(pwd)
    # create temp dir and cd to it
    local tmp_dir=$(mktemp -d $TMPDIR.XXXXXX) && cd $tmp_dir
    # download installer
    curl -sL "$url" > "tmp-$$.sh"
    # run with ELLIPSIS env var set
    ELLIPSIS=1 sh "tmp-$$.sh"
    # change back to original dir and clean up
    cd $cwd
    rm -rf $tmp_dir
}

utils.strip_colors() {
    echo "$@" | sed -e 's/\[[^m]*m//g'
}
