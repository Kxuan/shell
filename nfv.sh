#NFV_TESTCASES=
#VIRTUAL_ENV=
nfvprepare() {
    if [[ $# -ne 2 ]]; then
        echo "nfvprepare <virtual_env> <testcase_dir>" >&2
        return 1
    fi
    if [[ ! -d $1 ]] && ! mkdir -p $1; then
        echo "Can not create $1" >&2
        return 1
    fi
    
    target=$(readlink -f $1)
    escaped_target=${target//\//\\\/}
    cp -vpr --parents /etc/avocado/ $1
    mkdir -p $1/results
    sed -i '/xml_path/ c \
xml_path = '$(readlink -f $1)'/results/
s/\/etc\/avocado/'$escaped_target'/' $1/etc/avocado/conf.d/uvp_virt.conf 
    echo "$2" >> $1/testcase_dir.conf
}
nfvsetup() {
    if [[ $# -ne 1 ]]; then
        echo "nfvsetup <virtual_env>" >&2
        return 1
    fi  

    local path=$(readlink -f $1)
    if [[ ! -r $path/testcase_dir.conf ]]; then
        echo "$path is not a nfv environment. Use nfvprepare." >&2
        return 1
    fi
    
    NFV_TESTCASES=$(<$path/testcase_dir.conf)
    export VIRTUAL_ENV=$path
}
_nfv_choose() {
    local sel=$1
    shift
    local -a data=($@)

    if [[ -n $sel ]]; then
        echo ${data[$sel - 1]}
        return 0
    fi
    case ${#data[@]} in
       0) echo "not found" >&2; return 1;; 
       1) echo ${data[0]} ;;
       *) select path in ${data[@]}; do
           echo $path
           return
        done ;;  
    esac
}
nfvcd() {
    local dir nfv

    dir=$(find $NFV_TESTCASES -name $1)
    if [[ -z $dir ]]; then
        echo "Not found" >&2
        return 1
    fi

    path=$(_nfv_choose "$2" $(find $dir -name 'test.py' | sort))
    if [[ ! -f $path ]]; then
        echo "Not found" >&2
        return 1
    fi
    cd `dirname $path` 
}
nfv() {
    if [[ ! -d $VIRTUAL_ENV ]] || [[ ! -d $NFV_TESTCASES ]]; then
        echo "Error! Please use nfvsetup to setup nfv environment"
        return 2
    fi  
    nfvcd "$@" && time avocado run test.py -m test.yaml --show
}

