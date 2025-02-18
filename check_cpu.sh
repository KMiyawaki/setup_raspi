#!/bin/bash

function calc() {
    awk "BEGIN {print $*}"
}

function main(){
    local -r TEMP=`cat /sys/class/thermal/thermal_zone0/temp`
    echo "cpu temp:$(calc "${TEMP} / 1000.0")"
    for i in {0..3} ; do
        local CUR=`cat /sys/devices/system/cpu/cpu${i}/cpufreq/scaling_cur_freq`
        local MIN=`cat /sys/devices/system/cpu/cpu${i}/cpufreq/scaling_min_freq`
        local MAX=`cat /sys/devices/system/cpu/cpu${i}/cpufreq/scaling_max_freq`
        echo "CPU${i} min:$(calc "${MIN}/1000000.0")GHz max:$(calc "${MAX}/1000000.0")GHz cur:$(calc "${CUR}/1000000.0")GHz"
    done
}

main "$@"
