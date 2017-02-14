#!/bin/bash
cd $(dirname $0)
source ../config/scripts.conf
source $BASEDIR/scripts/inc_lock.sh 
lock $LOCK_NAME
source $BASEDIR/scripts/inc_error.sh
mkdir -p $STATUS_DIR
PID=$(cat $PID_FILE) 
[ -f $PID_FILE ] && rm -f $PID_FILE
[ ! -z $PID ] && [ -e /proc/$PID ] && kill $PID
sleep 1
[ ! -z $PID ] && [ -e /proc/$PID ] && echo $PID > $PID_FILE
[ -f $STN_FILE ] && rm -f $STN_FILE
unlock $LOCK_NAME
