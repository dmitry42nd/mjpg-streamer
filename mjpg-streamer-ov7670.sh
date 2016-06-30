#!/bin/sh

### BEGIN INIT INFO
# Provides:          app
# Required-Start:    
# Required-Stop:     
# Should-Start:      
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: start App MJPG_STREAMER
### END INIT INFO

CURRENT_MJPG_STREAMER_NAME=current-mjpg-streamer
CURRENT_MJPG_STREAMER_PATH=/etc/trik/$CURRENT_MJPG_STREAMER_NAME

MJPG_STREAMER_NAME=$(basename $0)
[ $MJPG_STREAMER_NAME==*.sh ] && MEDIA_SENSOR_NAME=${MEDIA_SENSOR_NAME%.*}

#MJPG_STREAMER_NAME=mjpg_streamer
MJPG_STREAMER_PATH=/usr/bin
MJPG_STREAMER_PRIORITY=-1
 
MJPG_STREAMER_PIDDIR=/var/run/
MJPG_STREAMER_PID=$PIDDIR/$NAME.pid

. /etc/init.d/functions

test -x $MJPG_STREAMER_PATH/$NAME || exit 0

enviroment () {
        export LD_LIBRARY_PATH=$MJPG_STREAMER_PATH:$LD_LIBRARY_PATH
        cd $MJPG_STREAMER_PATH
}

do_start() {
    enviroment
    echo -e "#!/bin/sh\n /etc/init.d/$MJPG_STREAMER_NAME $VARS reload" > $CURRENT_MJPG_STREAMER_PATH
    killall -g CURRENT_MJPG_STREAMER_NAME
    exit 0
}

do_reload() {
    enviroment
    case $MJPG_STREAMER_NAME in
        *-ov7670)
            mjpg_streamer -i "input_fifo.so" -o "output_http.so -w /www" > /dev/null 2>&1 &
            sleep 1
            status mjpg_streamer
            rc=$?
            wait
            exit $rc
            ;;
        *-webcam)
            mjpg_streamer -i "input_uvc.so -d /dev/video2 -r 432x240 -f 30" -o "output_http.so -w /www" > /dev/null 2>&1 &
            sleep 1
            status mjpg_streamer
            rc=$?
            wait
            exit $rc
            ;;
        *)
            log "unknown mjpg streamer command" 0 # unknown option
            exit 1
            ;;
}

do_stop() {
    start-stop-daemon -Kvx $MJPG_STREAMER_NAME
}

case $1 in
    reload)
        echo -n "Starting  $MJPG_STREAMER_NAME daemon : "
        do_reload
        ;;
    start)
        echo -n "Starting  $MJPG_STREAMER_NAME daemon : "
        do_start
        ;;
    stop)
        echo -n "Stopping $MJPG_STREAMER_NAME daemon: "
        do_stop
        ;;
    restart|force-reload)
        echo -n "Restarting $MJPG_STREAMER_NAME daemon: "
        do_stop
        do_start
        ;;
    status)
        enviroment
        status $MJPG_STREAMER_NAME
        exit $?
        ;;
    *)
        echo "Usage: $0 {start|stop|force-reload|restart|status}"
        exit 1
        ;;
esac
exit 0
