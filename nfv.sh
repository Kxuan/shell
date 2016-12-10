NFV_TESTCASES=
VIRTUAL_ENV=
nfvsetup() {
    if [[ $# -ne 2 ]]; then
        echo "nfvsetup <testcase_dir> <virtual_env>" >&2
        return 1
    fi  
    for dir; do
        echo "$dir is not an directory!"
    done

    NFV_TESTCASES=$1
    export VIRTUAL_ENV=$2
}
nfvcd() {
    cases=($(find $NFV_TESTCASES -name $1))
    case ${#cases[@]} in
       0) echo "not found"; return 1;; 
       1) path=${cases[0]} ;;
       *)  
    select path in ${cases[@]}; do
    break
    done
    ;;  
    esac
    tests=($(find $path -name 'test.py'))
    case ${#tests[@]} in
        0) echo "no test.py"; return 1;; 
        1) cd `dirname ${tests[0]}` || return;;
        *) select path in ${tests[@]}; do
    cd `dirname $path` || return
    break
    done;;
    esac
    return 0
}
nfv() {
    if [[ ! -d $VIRTUAL_ENV ]] || [[ ! -d $NFV_TESTCASES ]]; then
        echo "Error! Please use nfvsetup to setup nfv environment"
        return 2
    fi  
    nfvcd $1 && time avocado run test.py -m test.yaml --show
}

