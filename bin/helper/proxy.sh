
proxy_setup() {
    export http_proxy=http://127.0.0.1:8123/
    export https_proxy=http://127.0.0.1:8123/
}
proxy_start() {
    ssh lufq@192.168.20.95 -NnCf -L8123:127.0.0.1:8123
    proxy_setup
}
proxy_stop() {
    local pid
    pid=$(netstat -ntpl 2>/dev/null | grep '127.0.0.1:8123'| sed -e 's/^.*\s\([0-9][0-9]*\)\/ssh.*$/\1/g')
    ps $pid
    read -n1 -p "Kill the process? [Y/n]" ans
    if [[ $ans != "n" ]] && [[ $ans != "N" ]]; then
        echo "Killing $pid"
        kill -INT $pid
    fi
    unset http_proxy
    unset https_proxy
}
proxy_check() {
    netstat -ntpl 2>/dev/null | grep -q '127.0.0.1:8123'
}
proxy_check && proxy_setup && echo "Proxy [ok]"
