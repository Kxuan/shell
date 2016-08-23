#!/bin/bash
declare -a GO_go_history
if [[ -z $GOTO_PATH_HINTS_FILE ]]; then
GOTO_PATH_HINTS_FILE=~/bin/.go.hints
fi

__GO_search() {
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
    done < $GOTO_PATH_HINTS_FILE
    return 0
}

go() {
    local go_dist
    go_dist=$(__GO_search $1)

    if [[ -z $go_dist ]]; then
        echo "Hint missing" >&2
        return 1
    fi

    if cd $go_dist; then
        local gohc=${#GO_go_history[*]}
        GO_go_history[$gohc]=$OLDPWD
    fi
    return 0
}
go_mark_here() {
    local hint=$1
    if [[ -z $hint ]] ;then
        echo "Require a hint." >&2
        return 1
    fi
    
    if __GO_search $hint; then
        echo "The hint is already taken" >&2
        return 1
    fi

    echo "$hint $PWD" >> $GOTO_PATH_HINTS_FILE
    return 0
}
back() {
    local gohc=${#GO_go_history[*]}
    let gohc-=1
    if [[ $gohc -lt 0 ]]; then
        echo "Go history is empty" >&2
        return 1
    fi
    cd ${GO_go_history[gohc]}
    unset GO_go_history[gohc]
}

__go_complete() {
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
    done < $GOTO_PATH_HINTS_FILE
    ))
    return 0
}
complete -F __go_complete -o nospace go
