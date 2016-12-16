#NFV_TESTCASES=
#VIRTUAL_ENV=
nfvprepare() {
    if [[ ! -d /etc/avocado ]]; then
        echo "You need to install avocado & uts test framework before using this script"
        return 2
    fi
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

    if [[ -n $(ls $target) ]]; then
        echo "Warning: target is not empty, config file will NOT overwrite"
    else
        cp -vpr --parents /etc/avocado/ $target

        mkdir -p $target/results
        sed -i '/^xml_path/ c \
xml_path = '$target'/results/latest' $target/etc/avocado/conf.d/uvp_virt.conf
        sed -i '/^logs_dir/ c \
logs_dir = '$target'/results/' $target/etc/avocado/avocado.conf
        sed -i 's/\/etc\/avocado/'$escaped_target'\/etc\/avocado/' $(find $target/etc/avocado/ -name '*.conf')
    fi

    # save test case file
    readlink -f $2 > $target/testcase_dir.conf

    echo "
New test environment created!

Virtual Environment: $target
Test Log: $target/results/

Please note:
Only the configuration files (/etc/avocado) are redirected.
The files like virtual disk images, temporary files are not redirected. If you need to use them at the same time, please configure them manually."
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
    local _cf=$(tput setaf 5;tput bold) _cb=$(tput setaf 7)
    PS1="$_cb[$_cf$(dirname $path)$_cb]$PS1"
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
    if [[ ! -d $NFV_TESTCASES ]]; then
        echo "Virtual Env ($NFV_TESTCASES) is not a directory" >&2
        return 2
    fi

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
    if [[ ! -d $VIRTUAL_ENV ]]; then
        echo "Error: Please use nfvsetup to setup nfv environment"
        return 2
    fi  
    if [[ ! -d $NFV_TESTCASES ]]; then
        echo "Error: Please use nfvsetup to setup nfv environment"
        return 2
    fi
    nfvcd "$@" && time avocado run test.py -m test.yaml --show
}

