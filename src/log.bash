# log.bash
#
# Logging utilities.

load msg

# Print log message and store to logfile
log.store() {
    local err_type="$1"
    local msg="${@:2}"
    local timestamp="$(date +"%y/%m/%d %H:%M:%S")"

    # Also ouput message to terminal
    msg.print "$err_type $msg"

    # Prepend extension name to message if needed
    if [ -n "$ELLIPSIS_XNAME" ]; then
        msg="$ELLIPSIS_XNAME : $msg"
    fi

    # Write to log
    msg.log "$timestamp: $err_type $msg" >> ${ELLIPSIS_LOGFILE:-"/tmp/ellipsis.log"}
}

# Log success
log.ok() {
    log.store "[\033[32m ok \033[0m]" "$@"
}

# Log info
log.info() {
    log.store "[\033[36minfo\033[0m]" "$@"
}

# Log warning
log.warn() {
    log.store "[\033[33mwarn\033[0m]" "$@"
}

# Log error
log.error() {
    log.store "[\033[31m err\033[0m]" "$@"
}

# Log failure
log.fail() {
    log.store "[\033[31mFAIL\033[0m]" "$@"
}

# Deprecated; use msg.dim
log.dim() {
    msg.dim "$@"
}
