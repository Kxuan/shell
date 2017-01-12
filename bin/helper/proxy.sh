_PROXY_LOCAL_ADDRESS=127.0.0.1:8123
proxy_setup() {
    export http_proxy=http://${_PROXY_LOCAL_ADDRESS}/
    export https_proxy=http://${_PROXY_LOCAL_ADDRESS}/
}
proxy_start() {
    ssh lufq@192.168.20.95 -NnCf -L*:8123:${_PROXY_LOCAL_ADDRESS}
    proxy_setup
}
proxy_stop() {
    local pid
    pid=$(ss -Hnp -4 state listening 'src '${_PROXY_LOCAL_ADDRESS}'' | grep -oP 'pid=\d+' | cut -d= -f2)
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
    netstat -ntpl 2>/dev/null | grep -q '${_PROXY_LOCAL_ADDRESS}'
}
proxy_check && proxy_setup && echo "Proxy [ok]"
