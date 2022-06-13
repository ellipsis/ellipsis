# msg.bash
#
# Functions to show messages to the user

load utils

# Show message
msg.print() {
    if [ -t 1 ] || utils.is_true "$ELLIPSIS_FORCE_COLOR"; then
        echo -e "$(msg.tabs)$@"
    else
        msg.log "$(msg.tabs)$@"
    fi
}

# Show message without colors
msg.log() {
    utils.strip_colors "$(echo -e "$@")"
}

# Show bold message
msg.bold() {
    msg.print "\033[1m$@\033[0m"
}

# Show dim message
msg.dim() {
    msg.print "\033[90m$@\033[0m"
}

msg.tabs() {
    for (( n=1; n<"$ELLIPSIS_LVL"; n++ )); do
        printf '    '
    done
}
