#!/usr/bin/env bash
#
# os.sh
# Platform detection and OS functions.

# platform detection
os.platform() {
    case "$(uname | tr '[:upper:]' '[:lower:]')" in
        cygwin*)
            echo cygwin
            ;;
        darwin)
            echo osx
            ;;
        freebsd)
            echo freebsd
            ;;
        linux)
            echo linux
            ;;
    esac
}
