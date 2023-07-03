#!/bin/sh
CONF=/etc/config/qpkg.conf
QPKG_NAME="Clash"
QPKG_ROOT=`/sbin/getcfg $QPKG_NAME Install_Path -f ${CONF}`
APACHE_ROOT=`/sbin/getcfg SHARE_DEF defWeb -d Qweb -f /etc/config/def_share.info`
CONFIG_DIR=/share/Public/clash
if [ ! -d $CONFIG_DIR ]; then
    mkdir -p $CONFIG_DIR
fi
# $CONFIG_DIR/url.txt
if [ ! -f $CONFIG_DIR/url.txt ]; then
    touch $CONFIG_DIR/url.txt
fi
WEBUI_DIR=$QPKG_ROOT/web
SUBURL=$(cat $CONFIG_DIR/url.txt)
export QNAP_QPKG=$QPKG_NAME
export QPKG_NAME QPKG_ROOT

case "$1" in
  start)
    ENABLED=$(/sbin/getcfg $QPKG_NAME Enable -u -d FALSE -f $CONF)
    if [ "$ENABLED" != "TRUE" ]; then
        echo "$QPKG_NAME is disabled."
        exit 1
    fi

# start daemon
# $CONFIG_DIR/config.yaml存在则备份
if [ -f $CONFIG_DIR/config.yaml ]; then
    mv $CONFIG_DIR/config.yaml $CONFIG_DIR/config.yaml.bak
fi
wget -O $CONFIG_DIR/config.yaml $SUBURL
$QPKG_ROOT/clash -d  $CONFIG_DIR -ext-ui $WEBUI_DIR &
echo "0 6 * * * $QPKG_ROOT/clash.sh restart" >> /etc/config/crontab
crontab /etc/config/crontab && /etc/init.d/crond.sh restart
    ;;

  stop)

# kill all running processes
/bin/kill -9 `/bin/pidof clash`
# remove cronjob
sed -i "\|${QPKG_ROOT}/clash.sh restart|d" /etc/config/crontab
crontab /etc/config/crontab && /etc/init.d/crond.sh restart
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
