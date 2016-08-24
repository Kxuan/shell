
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

__pkg_complete() {
    local __pkg_actions=(iu su systemupgrade sys i in inst install a add r re remove u un unst uninstall s se search f file path filename l list)
    local cur=$2
    COMPREPLY=()

    #Complete the action
    if ((COMP_CWORD == 1)); then
        for i in ${__pkg_actions[@]}
        do
            if [[ $i == $cur ]]; then
                COMPREPLY=($cur)
                return 0
            fi
        done
        _arch_compgen "${__pkg_actions[@]}"
        return 0
    fi

    local action=${COMP_WORDS[1]}
    case $action in 
        iu|su|systemupgrade|sys);;
        f|file|path|filename);;
        i|in|inst|install|a|add|s|se|search|l|list)
            _pacman_pkg Slq;;
        r|re|remove|u|un|unst|uninstall)
            _pacman_pkg Qqe;;
    esac 
    return 0
}
_completion_loader pacman
complete -F __pkg_complete -o default pkg
