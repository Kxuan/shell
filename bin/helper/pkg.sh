pkg() {
    local action=$1
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
        u|up|update)
            sudo pacman -Sy
            ;;
        i|inst|install|a|add)
            sudo pacman -S --color=always --noconfirm $@ ;;
        if|info)
            pacman -Si $@
            ;;
        r|re|remove|un|uninstall)
            sudo pacman -Rsc --color=always $@ ;;
        s|se|search)
            pacsearch $@
            ;;
        f|file|path|filename)
            pkgfile -srv $@
            ;;
        b|bin|binary)
            pkgfile -srv '\/s?bin\/'$1'$' ;;
        l|list)
            pkgfile -l $@ ;;
            
        *) return 1;;
    esac
}

__pkg_complete() {
    local __pkg_actions=(
iu su systemupgrade sys
u up update
i inst install a add
if info
r re remove un uninstall
s se search
f file path filename
b bin binary
l list )
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
        i|inst|install|a|add|s|se|search|l|list|if|info)
            _pacman_pkg Slq;;
        r|re|remove|un|uninstall)
            _pacman_pkg Qqe;;
        b|bin|binary)
            _arch_compgen `pkgfile -rv '/s?bin/'$cur'\w*$' | while read line; do 
                fields=($line)
                IFS=/ fields=(${fields[2]})
                len=${#fields[@]}
                let len-=1
                echo ${fields[len]}
            done`
        ;;
    esac 
    return 0
}
_completion_loader pacman
complete -F __pkg_complete -o default pkg
