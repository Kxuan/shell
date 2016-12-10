NFV_TESTCASES=
VIRTUAL_ENV=
nfvprepare() {
    if [[ $# -ne 2 ]]; then
        echo "nfvprepare <virtual_env> <testcase_dir>" >&2
        return 1
    fi
    if [[ ! -d $1 ]] && ! mkdir -p $1; then
        echo "Can not create $1" >&2
        return 1
    fi

    cp -vpr --parents /etc/avocado/ $1
    echo "$2" >> $1/testcase_dir.conf
}
nfvsetup() {
    if [[ $# -ne 1 ]]; then
        echo "nfvsetup <virtual_env>" >&2
        return 1
    fi  
    if [[ ! -r $1/testcase_dir.conf ]]; then
        echo "$1 is not a nfv environment. Use nfvprepare." >&2
        return 1
    fi

    NFV_TESTCASES=$(<$1/testcase_dir.conf)
    export VIRTUAL_ENV=$1
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

