#!/bin/bash
#set -ex
cd $(dirname $0)
source ../config/scripts.conf
VOLUME_RANGE_STR=$(amixer get $CONTROL_NAME | grep 'Limits: Playback' | sed -e 's/.*Playback//g' | sed -e 's/ \- /:/g')
MIN_VOLUME=$(echo $VOLUME_RANGE_STR | cut -d':' -f 1)
MAX_VOLUME=$(echo $VOLUME_RANGE_STR | cut -d':' -f 2)
VOL_RANGE=$[ $MAX_VOLUME - $MIN_VOLUME ]

amixer -M > /dev/null 2>&1 && AMIXER_HAS_NON_LINEAR_SCALING="y"

function get_mute_state(){
    amixer get $CONTROL_NAME | tail -n 1 | egrep -o  "\[o[fn]f?\]" | tr -d [\[\]]
}

function get_volume(){
    amixer get $CONTROL_NAME | tail -n 1 | egrep -o \(\-\|''\)[0-9]* | head -n 1
}

function volum_abs_to_rel(){
    local abs_val=$1
    local norm_val=$(echo "100 * ((( $abs_val - $MIN_VOLUME ) / $VOL_RANGE ) ^4)" | bc -l)
    stripped_val=$(echo ${norm_val} | sed -e 's/\..*//g')
    echo ${stripped_val:-0}
}

function get_volume_percent(){
    if [ "x${AMIXER_HAS_NON_LINEAR_SCALING}" == "xy" ];then
        amixer get -M $CONTROL_NAME | tail -n 1 | egrep -o [0-9]*\% | egrep -o [0-9]*
    else
        echo $(volum_abs_to_rel $(get_volume))
    fi
}

function set_volume_percent(){
    local target=$1
    [ $target -gt 100 ] && target=100
    [ $target -lt 0 ] && target=0
    if [ "x${AMIXER_HAS_NON_LINEAR_SCALING}" == "xy" ];then
        amixer -M -- set $CONTROL_NAME ${target}%
    else
        local target_abs=$(echo "$MIN_VOLUME + $VOL_RANGE * sqrt(sqrt( $target / 100))" | bc -l)
        amixer -- set $CONTROL_NAME ${target_abs%.*}
    fi
}

function volume_change_percent(){
    local delta=$1
    local current=$(get_volume_percent)
    local new=$[ $current + $delta ] 
    set_volume_percent $new
}

COMMAND=$1
case $COMMAND in
	'tmute')
		amixer set $CONTROL_NAME toggle > /dev/null 2>&1
		;;
	'up')
        if [ "x${AMIXER_HAS_NON_LINEAR_SCALING}" == "xy" ];then
            amixer -M set ${MASTER_NAME} 10%+
        else
            volume_change_percent 10 > /dev/null 2>&1
        fi
		;;
	'down')
        if [ "x${AMIXER_HAS_NON_LINEAR_SCALING}" == "xy" ];then
            amixer -M set ${MASTER_NAME} 10%-
        else
            volume_change_percent -10 > /dev/null 2>&1
        fi
		;;
    'get')
        if [ "off" == "$(get_mute_state)" ];then
            echo "M";
        else 
            echo $(get_volume_percent)"%"
        fi
        ;; 
	*)
		echo "Invalid argument $COMMAND"
		exit -1
		;;
esac
