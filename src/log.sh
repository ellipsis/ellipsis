#!/usr/bin/env bash
#
# log.sh
# Logging utilities.

log.info() {
    echo -e "\033[33minfo\033[0m" "$@"
}

log.error() {
    echo -e "\033[31merror\033[0m" "$@"
}

log.warn() {
    echo -e "\033[33mwarn\033[0m" "$@"
}
