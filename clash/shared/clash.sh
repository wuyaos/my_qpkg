#!/bin/sh
CONF=/etc/config/qpkg.conf
QPKG_NAME="Clash"
QPKG_ROOT=`/sbin/getcfg $QPKG_NAME Install_Path -f ${CONF}`
APACHE_ROOT=`/sbin/getcfg SHARE_DEF defWeb -d Qweb -f /etc/config/def_share.info`
CONFIG_DIR=/share/Public/clash
if [ ! -d $CONFIG_DIR ]; then
    mkdir -p $CONFIG_DIR
    cp -rf $QPKG_ROOT/config.example.yaml $CONFIG_DIR/config.yaml
fi
WEBUI_DIR=$QPKG_ROOT/web
export QNAP_QPKG=$QPKG_NAME
export QPKG_NAME QPKG_ROOT

case "$1" in
  start)
    ENABLED=$(/sbin/getcfg $QPKG_NAME Enable -u -d FALSE -f $CONF)
    if [ "$ENABLED" != "TRUE" ]; then
        echo "$QPKG_NAME is disabled."
        exit 1
    fi

/bin/ln -sf $QPKG_ROOT /opt/$QPKG_NAME
/bin/ln -sf $QPKG_ROOT/clash /usr/bin/clash
# start daemon
clash -d  $CONFIG_DIR -ext-ui $WEBUI_DIR > $CONFIG_DIR/log.txt &
    ;;

  stop)

# kill all running processes
/bin/kill -9 `/bin/pidof clash`
rm -rf /usr/bin/clash
rm -rf /opt/$QPKG_NAME


    ;;

  restart)
    $0 stop
    $0 start
    ;;

  *)
    echo "Usage: $0 {start|stop|restart}"
    exit 1
esac

exit 0
