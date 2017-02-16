#!/bin/bash
cd $(dirname $0)
source ../config/scripts.conf
source $BASEDIR/scripts/inc_lock.sh
lock $LOCK_NAME
source $BASEDIR/scripts/inc_error.sh 
mkdir -p $STATUS_DIR

# check previous process
if [ -f $PID_FILE ];then
    PID=$(cat $PID_FILE | tr -d ' ') 
   [ ! -z $PID ] && [ -e /proc/$PID ] && abort "Old process still running!" 
fi

STN=$1
[ -z $STN ] && abort "No station name given"
source <(grep "^${STN}=" $STATIONS_CONF)
URL=${!STN}
[ -z $URL ] && abort "Station \"$STN\" not found"
echo $URL
EXTEN=${URL##*.}
echo $EXTEN
PLAYER=$(egrep "^${EXTEN} " $PLAYERS_CONF | cut -d" " -f 2)
[ -z $PLAYER ] && EXTEN=default
PLAYER=$(egrep "^${EXTEN} " $PLAYERS_CONF | cut -d" " -f 2)
[ -z $PLAYER ] && abort "No suitable player found for extension \"$EXTEN\""
echo $STN > $STN_FILE
$PLAYER $URL &
echo $! > $PID_FILE
unlock $LOCK_NAME
