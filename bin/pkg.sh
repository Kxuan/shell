
pkg() {
    action=$1
    shift
    case $action in
        iu|su|systemupgrade|sys)
            read -N 1 -p "Are you sure upgrade the system? 
Warning: The pacman cache will be erased, regardless upgrade successful or not.
(y/N)"
            if [[ $REPLY == 'y' ]] || [[ $REPLY == 'Y' ]]; then
                sudo pacman -S -cc --noconfirm
                sudo pacman -S -u -yy --color=always --force
            else
                return 2
            fi
            ;;
        i|in|inst|install|a|add)
            sudo pacman -S --color=always --noconfirm $@ ;;
        r|re|remove|u|un|unst|uninstall)
            sudo pacman -Rsc --color=always $@ ;;
        s|se|search)
            pacsearch $@ ;;
        f|file|path|filename)
            pkgfile -srv $@ ;;
        l|list)
            pkgfile -l $@ ;;
        *) return 1;;
    esac
}
