#!/bin/sh
CONF=/etc/config/qpkg.conf
QPKG_NAME="nastools"
QPKG_ROOT=`/sbin/getcfg $QPKG_NAME Install_Path -f ${CONF}`
APACHE_ROOT=`/sbin/getcfg SHARE_DEF defWeb -d Qweb -f /etc/config/def_share.info`
export QNAP_QPKG=$QPKG_NAME
CONFIG_DIR=/share/Public/nastools
if [ ! -d $CONFIG_DIR ]; then
  mkdir -p $CONFIG_DIR
fi
export NASTOOL_CONFIG=$CONFIG_DIR/config.yaml
export NASTOOL_LOG=$CONFIG_DIR/logs
Python3_ROOT=`/sbin/getcfg "Python3" Install_Path -f ${CONF}`
Python3=$Python3_ROOT/python3/bin/python3

case "$1" in
  start)
    ENABLED=$(/sbin/getcfg $QPKG_NAME Enable -u -d FALSE -f $CONF)
    if [ "$ENABLED" != "TRUE" ]; then
        echo "$QPKG_NAME is disabled."
        exit 1
    fi
    $Python3 -m pip install -r $QPKG_ROOT/nas-tools/requirements.txt
    if [ $? -ne 0 ]; then
      /sbin/log_tool -t 2 -N "NAS Tool" -G "NAS Tool" -a "Python3 依赖包安装失败。"
    fi
    CONFIG_DIR=/share/Public/nastools
    export NASTOOL_CONFIG=$CONFIG_DIR/config.yaml
    export NASTOOL_LOG=$CONFIG_DIR/logs
    $Python3 -u $QPKG_ROOT/nas-tools/run.py &
    # add restart cronjob to avoid rss not working bug
    echo "0 1 * * * $QPKG_ROOT/nastools.sh restart" >> /etc/config/crontab
    crontab /etc/config/crontab && /etc/init.d/crond.sh restart
    ;;

  stop)
    pid=$(ps -ef | grep "python3 -u $QPKG_ROOT/nas-tools/run.py" | grep -v grep | awk '{print $1}')
		kill -9 $pid
    # remove cronjob
    sed -i "\|${QPKG_ROOT}/nastools.sh restart|d" /etc/config/crontab
    crontab /etc/config/crontab && /etc/init.d/crond.sh restart
    ;;

  restart)
    $0 stop
    $0 start
    ;;
  remove)
    ;;

  *)
    echo "Usage: $0 {start|stop|restart|remove}"
    exit 1
esac

exit 0
