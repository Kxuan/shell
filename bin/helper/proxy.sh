_proxy_arg() {
    [[ -z $PROXY_REMOTE_ADDRESS ]] && PROXY_REMOTE_ADDRESS=127.0.0.1:8123
    [[ -z $PROXY_REMOTE_HOST ]] && PROXY_REMOTE_HOST=zhaizx@10.167.226.34
    [[ -z $PROXY_LOCAL_ADDRESS ]] && PROXY_LOCAL_ADDRESS='127.0.0.1:8123'
}
proxy_setup() {
    local PROXY_LOCAL_ADDRESS PROXY_REMOTE_HOST PROXY_REMOTE_ADDRESS
    _proxy_arg
    export http_proxy=http://${PROXY_LOCAL_ADDRESS}/
    export https_proxy=http://${PROXY_LOCAL_ADDRESS}/
}
proxy_start() {
    local PROXY_LOCAL_ADDRESS PROXY_REMOTE_HOST PROXY_REMOTE_ADDRESS
    _proxy_arg
    ssh ${PROXY_REMOTE_HOST} -NnCf -L${PROXY_LOCAL_ADDRESS}:${PROXY_REMOTE_ADDRESS}
}
proxy_stop() {
    local PROXY_LOCAL_ADDRESS PROXY_REMOTE_HOST PROXY_REMOTE_ADDRESS
    _proxy_arg
    local pid
    pid=$(ss -Hnp -4 state listening 'src '${PROXY_LOCAL_ADDRESS} | grep -oP 'pid=\d+' | cut -d= -f2)
    ps "$pid" || exit 1
    read -n1 -p "Kill the process? [Y/n]" ans
    if [[ $ans != "n" ]] && [[ $ans != "N" ]]; then
        echo "Killing $pid"
        kill -INT $pid
    fi
    unset http_proxy
    unset https_proxy
}
proxy_check() {
    local PROXY_LOCAL_ADDRESS PROXY_REMOTE_HOST PROXY_REMOTE_ADDRESS
    _proxy_arg
    ss -Hnp -4 state listening 'src '${PROXY_LOCAL_ADDRESS} | grep -qP 'pid=\d+'
}
proxy_check && proxy_setup && echo "Proxy [ok]"
