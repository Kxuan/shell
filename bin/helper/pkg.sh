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
        _arch_compgen \
a add bi binary f file filename i ib if info inst install installbinary iu l list path r re remove s se search su sys systemupgrade test u ui un uninstall up update

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
if [[ -n $BASH ]]; then
_completion_loader pacman
complete -F __pkg_complete -o default pkg
fi
