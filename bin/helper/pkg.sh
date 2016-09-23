_pkg_install_binary() {
    local bin_name=$1
    local packages=()
    local fields
    local i n
    local user_choice

    packages=($(pkgfile -sr '\/s?bin\/'$bin_name'$'))
    n=${#packages[@]}

    if [[ n -ge 1 ]]; then
        for ((i=0;i<n;i++)); do
            echo "$((i+1))) ${packages[i]}"
        done

        read -p "[1-$n]? " user_choice || return 1
        let user_choice-=1
        
        if [[ -z ${packages[user_choice]} ]]; then
            echo "Invalid choice" >&2
            return 1
        fi
    else
        user_choice=0
        read -p "Install ${packages[user_choice]}? [y/N]" -n1
        if [ "$REPLY" != y ] && [ "$REPLY" != Y ]; then
            return 1
        fi
    fi
    pkg i ${packages[user_choice]}
}
pkg() {
    local action=$1
    shift
    case $action in
        ui|iu|su|systemupgrade|sys)
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
            sudo pacman -Sy;;
        i|inst|install|a|add)
            sudo pacman -S --color=always --noconfirm $@ ;;
        if|info)
            pacman -Si $@ ;;
        r|re|remove|un|uninstall)
            sudo pacman -Rsc --color=always $@ ;;
        s|se|search)
            pacsearch $@;;
        f|file|path|filename)
            pkgfile -srv $@;;
        binary)
            pkgfile -bsv $1;;
        b|bin)
            pkgfile -srv '\/s?bin\/'$1'$' ;;
        bi|ib|installbinary)
            _pkg_install_binary $@;;
        l|list)
            pkgfile -l $@ ;;
            
        *) return 1;;
    esac
}

__pkg_complete_binary() {
    local -a fields
    local filename
    local IFS
    pkgfile -rv '/s?bin/'$1'\w*$' | while read line; do 
         IFS=$'\t '
         fields=($line)
         filename=${fields[2]}
         IFS=/
         fields=($filename)
         len=${#fields[@]}
         let len-=1
         echo ${fields[len]}
         IFS=$'\n'
     done
}
__pkg_complete() {
    local __pkg_actions=(
ui iu su systemupgrade sys
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
            COMPREPLY=($(__pkg_complete_binary $cur))
        ;;
    esac 
    return 0
}
_completion_loader pacman
complete -F __pkg_complete -o default pkg
