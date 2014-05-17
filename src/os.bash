# os.bash
#
# Platform detection and OS functions.

os.platform() {
    case "$(uname)" in
        CYGWIN*)
            echo cygwin
            ;;
        Darwin)
            echo osx
            ;;
        FreeBSD)
            echo freebsd
            ;;
        Linux)
            echo linux
            ;;
    esac
}
