#!/bin/bash

run() {
    local opt arg
    local pid
    local mode
    local signal=SIGINT
    local sleeptime

    local OPTIND=1
    while getopts :ft:s: opt $@; do
    case $opt in
        f) mode=waitsuccess;;
        t) mode=timed;sleeptime=$OPTARG;;
        s) signal=$OPTARG;;
    esac
    shift $((OPTIND-1))
    done

    case $mode in 
        waitsuccess)
            while ! $@;do :;done
            ;;
        timed)
            $@ &
            pid=$!
            sleep $sleeptime
            kill -$signal $pid
            wait $pid
            ;;
    esac 
}
