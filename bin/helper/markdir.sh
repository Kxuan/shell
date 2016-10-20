#!/bin/bash
declare -a MARKDIR_history
if [[ -z $MARKDIR_HINTS_FILE ]]; then
MARKDIR_HINTS_FILE=~/bin/.go.hints
fi

_MARKDIR_search() {
    local pattern=$1
    local line filename
    local name
    local fields

    pattern=${pattern^^}
    pattern=$(sed 's/./&*/g' - <<< $pattern)
    pattern='*'$pattern
    while read line
    do
        fields=($line)
        name=${fields[0]^^}
        if [[ $name == $pattern ]]; then
            echo ${line#* }
            return 0
        fi
    done < $MARKDIR_HINTS_FILE
    for filename in *
    do
        name=${filename^^}
        if [[ -d $filename ]] && [[ $name == $pattern ]]; then
            echo $filename
            return 0
        fi
    done
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
_MARKDIR_pushd() {
    local gohc=${#MARKDIR_history[*]}
    MARKDIR_history[$gohc]=$1
}
_MARKDIR_popd() {
    local gohc=${#MARKDIR_history[*]}
    let gohc-=1
    if [[ $gohc -lt 0 ]]; then
        return 1
    fi
    \cd ${MARKDIR_history[gohc]}
    unset MARKDIR_history[gohc]
}

markdir_go() {
    local hint=$1
    local target_dir
    
    if [[ -z $hint ]]; then
        target_dir=$(readlink -f .)
    elif ! target_dir=$(_MARKDIR_search $hint); then
        # hint is not found. try to change directory to $hint
        target_dir=$hint
    fi

    \cd $target_dir && _MARKDIR_pushd $OLDPWD
}
markdir_markhere() {
    local hint=$1
    local target_dir

    if [[ -z $hint ]] ;then
        echo "Require a hint." >&2
        return 1
    fi
    
    if target_dir=$(_MARKDIR_get_path_from_hint $hint); then
        echo "\"$hint\" is already taken by \"$target_dir\"" >&2
        return 1
    fi

    echo "$hint $PWD" >> $MARKDIR_HINTS_FILE
}
markdir_back() {
    if ! _MARKDIR_popd ;then
        echo "Go history is empty" >&2
        return 1
    fi
    return 0
}
markdir_setup_alias() {
    local alias_go=$1
    local alias_back=$2
    local alias_mark=$3

    alias $alias_go=markdir_go
    alias $alias_back=markdir_back
    alias $alias_mark=markdir_markhere

    if [[ -n $BASH ]]; then
        complete -F __markdir_complete -o default $alias_go
    fi
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
    local hint=$2
    local pattern=$2
    local line name fields
    local reply

    local cur prev words cword split;
    _init_completion -s || return;

    pattern=${pattern^^}
    pattern=$(sed 's/./&*/g' - <<< $pattern)
    pattern='*'$pattern
    while read line
    do
        fields=($line)
        name=${fields[0]^^}
        if [ "$name" = "${hint^^}" ]; then
            COMPREPLY+=( $name )
            break
        elif [[ $name == $pattern ]]; then
            COMPREPLY+=( ${fields[0]} )
        fi
    done < $MARKDIR_HINTS_FILE

    if [[ ${#COMPREPLY[@]} -eq 1 ]]; then
        reply=$(_MARKDIR_get_path_from_hint ${COMPREPLY[0]})
        COMPREPLY=($reply)
        compopt -o nospace
    else
        _filedir
    fi
}
if [[ -n $BASH ]]; then
complete -F __markdir_complete -o default markdir_go
fi
