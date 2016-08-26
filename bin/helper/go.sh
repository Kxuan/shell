#!/bin/bash
declare -a MARKDIR_history
if [[ -z $MARKDIR_HINTS_FILE ]]; then
MARKDIR_HINTS_FILE=~/bin/.go.hints
fi

_MARKDIR_search() {
    local pattern=$1
    local line
    local hint
    local fields
    local go_dist

    pattern=${pattern^^}
    pattern=$(sed 's/./&*/g' - <<< $pattern)
    pattern='*'$pattern
    while read line
    do
        fields=($line)
        hint=${fields[0]^^}
        if [[ $hint == $pattern ]]; then
            go_dist=${line#* }
            echo $go_dist
            return 0
        fi
    done < $MARKDIR_HINTS_FILE
    return 1
}
_MARKDIR_get_path_from_hint() {
    local hint=$1
    local line
    local fields
    
    hint=${hint^^}
    while read line
    do
        fields=($line)
        if [ "${fields[0]^^}" = "$hint" ]; then
            echo ${line#* }
            return 0
        fi
    done < $MARKDIR_HINTS_FILE
    return 1
}

markdir_go() {
    local hint=$1
    local go_dist
    
    if ! go_dist=$(_MARKDIR_search $hint); then
        # hint is not found

        # if hint is a directory, just go there.
        [[ -d $hint ]] && \cd $hint
        return
    fi

    # we found a mached hint record. try to go there.
    if \cd $go_dist; then
        local gohc=${#MARKDIR_history[*]}
        MARKDIR_history[$gohc]=$OLDPWD
    fi
    return
}
markdir_markhere() {
    local hint=$1
    local go_dist

    if [[ -z $hint ]] ;then
        echo "Require a hint." >&2
        return 1
    fi
    
    if go_dist=$(_MARKDIR_get_path_from_hint $hint); then
        echo "\"$hint\" is already taken by \"$go_dist\"" >&2
        return 1
    fi

    echo "$hint $PWD" >> $MARKDIR_HINTS_FILE
}
markdir_back() {
    local gohc=${#MARKDIR_history[*]}
    let gohc-=1
    if [[ $gohc -lt 0 ]]; then
        echo "Go history is empty" >&2
        return 1
    fi
    \cd ${MARKDIR_history[gohc]}
    unset MARKDIR_history[gohc]
}
markdir_setup_alias() {
    local alias_go=$1
    local alias_back=$2
    local alias_mark=$3

    alias $alias_go=markdir_go
    alias $alias_back=markdir_back
    alias $alias_mark=markdir_markhere
    complete -F __markdir_complete -o default $alias_go
}
markdir_clean_alias() {
    local alias_go=$1
    local alias_back=$2
    local alias_mark=$3

    unalias $alias_go
    unalias $alias_back
    unalias $alias_mark
    complete -r $alias_go
}

__markdir_complete() {
    local pattern=$2
    local line
    local hint
    local fields
    local go_dist

    pattern=${pattern^^}
    pattern=$(sed 's/./&*/g' - <<< $pattern)
    pattern='*'$pattern
    COMPREPLY=($(
    while read line
    do
        fields=($line)
        hint=${fields[0]^^}
        if [[ $hint == $pattern ]]; then
            echo ${fields[0]}
        fi
    done < $MARKDIR_HINTS_FILE
    ))

    if [[ ${#COMPREPLY[@]} -eq 1 ]]; then
        COMPREPLY=($(_MARKDIR_get_path_from_hint ${COMPREPLY[0]}))
    fi
    return 0
}
complete -F __markdir_complete -o default markdir_go
