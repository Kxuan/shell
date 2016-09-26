_pkg_install_binary() {
    local bin_name=$1
    local packages=()
    local fields
    local i n
    local user_choice

    packages=($(pkgfile -sr '\/s?bin\/'$bin_name'$'))
    n=${#packages[@]}

    if ((n > 1)); then
        for ((i=0;i<n;i++)); do
            echo "$((i+1))) ${packages[i]}"
        done

        read -p "[1-$n]? " user_choice || return 1
        let user_choice-=1
        
        if [[ -z ${packages[user_choice]} ]]; then
            echo "Invalid choice" >&2
            return 1
        fi
    elif ((n == 0)); then
        echo "No binary file named $bin_name" >&2
        return 1
    else
        user_choice=0
        read -p "Install ${packages[user_choice]}? [y/N]" -n1
        if [ "$REPLY" != y ] && [ "$REPLY" != Y ]; then
            return 1
        fi
    fi
    pkg install ${packages[user_choice]}
}
_pkg_system_upgrade() {
    read -N 1 -p "Are you sure upgrade the system? 
Warning: The pacman cache will be erased, regardless upgrade successful or not.
(y/N)"
    if [[ $REPLY == 'y' ]] || [[ $REPLY == 'Y' ]]; then
        sudo pacman -S -u -yy --color=always --force
    else
        return 2
    fi

}
declare -Ag _pkg_action_map=(
["ui"]="_pkg_system_upgrade"
["iu"]="_pkg_system_upgrade"
["su"]="_pkg_system_upgrade"
["sys"]="_pkg_system_upgrade"
["systemupgrade"]="_pkg_system_upgrade"
["u"]="sudo pacman -Sy"
["up"]="sudo pacman -Sy"
["update"]="sudo pacman -Sy"
["i"]="sudo pacman -S --color=always --noconfirm"
["inst"]="sudo pacman -S --color=always --noconfirm"
["install"]="sudo pacman -S --color=always --noconfirm"
["a"]="sudo pacman -S --color=always --noconfirm"
["add"]="sudo pacman -S --color=always --noconfirm"
["if"]="pacman -Si"
["info"]="pacman -Si"
["r"]="sudo pacman -Rsc --color=always"
["re"]="sudo pacman -Rsc --color=always"
["remove"]="sudo pacman -Rsc --color=always"
["un"]="sudo pacman -Rsc --color=always"
["uninstall"]="sudo pacman -Rsc --color=always"
["s"]="pacsearch"
["se"]="pacsearch"
["search"]="pacsearch"
["f"]="pkgfile -srv"
["file"]="pkgfile -srv"
["path"]="pkgfile -srv"
["filename"]="pkgfile -srv"
["binary"]="pkgfile -bsv"
#["b"]=special "
#["bin"]=special"
["bi"]="_pkg_install_binary"
["ib"]="_pkg_install_binary"
["installbinary"]="_pkg_install_binary"
["l"]="pkgfile -l"
["list"]="pkgfile -l"
["test"]="echo"
)

pkg() {
    local IFS
    local action=$1
    shift

    case $action in
        b|bin)
            pkgfile -srv '\/s?bin\/'$1'$' ;;
        *)
        if [[ -n ${_pkg_action_map[$action]} ]]; then
            IFS=' '
            local cmds=(${_pkg_action_map[$action]})
            IFS=
            ${cmds[@]} $@
        else
            echo "unrecognized action $action" >&2
        fi
        ;;
    esac
}

__pkg_complete_binary() {
    local -a fields
    local filename
    local IFS
    while read line; do 
         IFS=$'\t '
         fields=($line)
         filename=${fields[2]}
         IFS=/
         fields=($filename)
         len=${#fields[@]}
         let len-=1
         COMPREPLY+=(${fields[len]})
         IFS=$'\n'
     done < <(pkgfile -rv '/s?bin/'$1'\w*$') 
}
__pkg_complete() {
    local cur=$2
    COMPREPLY=()

    #Complete the action
    if ((COMP_CWORD == 1)); then
        _arch_compgen "${!_pkg_action_map[@]}"
        return 0
    fi

    local action=${COMP_WORDS[1]}
    case $action in 
        i|inst|install|a|add|s|se|search|l|list|if|info)
            _pacman_pkg Slq;;
        r|re|remove|un|uninstall)
            _pacman_pkg Qqe;;
        b|bin|binary)
            __pkg_complete_binary $cur;;
    esac 
    return 0
}
_completion_loader pacman
complete -F __pkg_complete -o default pkg
