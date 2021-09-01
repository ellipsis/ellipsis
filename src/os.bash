# os.bash
#
# Platform detection and OS functions.

os.platform() {
    case "$(uname)" in
        CYGWIN*)
            echo cygwin
            ;;
        *WSL2|*microsoft-standard)
            echo wsl2
            ;;
        *Microsoft)
            echo wsl1
            ;;
        Darwin*)
            echo osx
            ;;
        FreeBSD*)
            echo freebsd
            ;;
        Linux*)
            echo linux
            ;;
    esac
}
