rebash_clean_env() {
    REBASH_EXEC_ARGS=-c
}
rebash() {
    local exec_path=$(readlink -f /proc/$$/exe)
    local IFS=$'\n'
    local -a args=$@
    local arg
    local has_zeroth_arg=false
    local zeroth_arg
    while IFS= read -r -d '' arg; do
        if ! $has_zeroth_arg; then
            zeroth_arg=$arg
            has_zeroth_arg=true
        else
            args+=($arg)
        fi
    done </proc/$$/cmdline
    
    echo exec -a $zeroth_arg $exec_path ${args[@]}
         exec -a $zeroth_arg $exec_path ${args[@]}
}
