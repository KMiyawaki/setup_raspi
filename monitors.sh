#!/bin/bash

function list(){
    xrandr | grep " connected " | awk '{ print$1 }'
}

function primary(){
    xrandr | grep " connected primary" | awk '{ print$1 }'
}

function switch(){
    local -r MONITORS=`list`
    local -r NUM=`list | wc -l `
    if [ ${NUM} -lt 2 ]; then
        echo "Only one monitor is connected."
        return        
    fi
    local -r PRI=`primary`
    for m in ${MONITORS}
    do
        if [ ${PRI} != ${m} ]; then
            echo "switch from ${PRI} to ${m}"
            xrandr --output ${m} --auto --primary --left-of ${PRI}
            return
        fi
    done
}

function main(){
  echo "Display switching"
  if [ $# -ne 1 ]; then
    echo "usage:${0} [-l|-p|-s]" 1>&2
    exit 1
  fi
  if [ ${1} = "-l" ]; then
    list
  elif [ ${1} = "-p" ]; then
    primary
  elif [ ${1} = "-s" ]; then
    switch
  fi
}

main "$@"