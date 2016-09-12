__cat_all_file_in_dir() {
    local prefix=$1
    local reverse=$2
    local next_line=$3
    local add_lf=$4
    local verbose=$5

    for f in *; do
        if [[ -f $f ]]; then
            echo -n $prefix$f":"
            $next_line && echo
            cat $f
            $add_lf && echo
        elif $reverse && [[ -d $f ]]; then
            pushd -- $f >/dev/null || continue
            if $verbose; then
                echo "Enter Directory: $PWD" >&2
                __cat_all_file_in_dir $prefix$f'/' $reverse $next_line $add_lf $verbose
                echo "Leave Directory: $PWD" >&2
            else
                __cat_all_file_in_dir $prefix$f'/' $reverse $next_line $add_lf $verbose
            fi
            popd >/dev/null
        fi
    done
}

catall() {
    local opt
    local reverse=false
    # insert a \n between filename and its content
    local next_line=false
    # insert a \n after file content
    local add_lf=false
    local verbose=false
    local dirs=(.)

    OPTIND=0
    while getopts rclv opt; do
    case $opt in
        r) reverse=true;;
        c) add_lf=true;;
        l) next_line=true;;
        v) verbose=true;;
    esac
    done
    shift $((OPTIND-1))

    if (( $# > 0 )); then
        dirs=($@)
    fi
    
    for dir in ${dirs[@]}; do
        pushd -- $dir >/dev/null || continue
        __cat_all_file_in_dir "" $reverse $next_line $add_lf $verbose
        popd >/dev/null
    done
}
