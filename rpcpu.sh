#!/usr/bin/env bash

get_all_children() {
    local pid=$1
    echo $pid
    for child in $(pgrep -P $pid); do
        get_all_children $child
    done
}

CHILDREN=$(get_all_children $1)
CPU=$(echo $CHILDREN | xargs -r ps -o %cpu= -p | awk '{s+=$1} END {print s}')
MEM=$(echo $CHILDREN | xargs -r ps -o %mem= -p | awk '{s+=$1} END {print s}')
echo $CPU $MEM
