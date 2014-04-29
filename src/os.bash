# os.bash
#
# Platform detection and OS functions.

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
