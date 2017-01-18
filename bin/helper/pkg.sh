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
__pkg_action_match() {
    bash -ic '. `which pkg`; _pkg_action_match "'$1'"'
}
__pkg_complete() {
    local cur=$2
    COMPREPLY=()

    if ((COMP_CWORD == 1)); then
        _arch_compgen $(__pkg_action_match \*)
        return 0
    fi

    local action=($(__pkg_action_match ${COMP_WORDS[1]}))
    case ${#action[@]} in 
        0) return ;;
        1) case ${action[0]} in 
            install|search|list|info)
                _pacman_pkg Slq;;
            remove|uninstall)
                _pacman_pkg Qqe;;
            bin*)
                __pkg_complete_binary $cur;;
           esac ;;
        *) COMPREPLY=(${action[@]}) ;;
    esac
    return 0
}
if [[ -n $BASH ]]; then
_completion_loader pacman
complete -F __pkg_complete -o default pkg
fi
