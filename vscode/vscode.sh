#!/bin/sh
CONF=/etc/config/qpkg.conf
QPKG_NAME="vscode"
QPKG_ROOT=`/sbin/getcfg $QPKG_NAME Install_Path -f ${CONF}`
APACHE_ROOT=`/sbin/getcfg SHARE_DEF defWeb -d Qweb -f /etc/config/def_share.info`
CONFIG_DIR=/share/Public/vscode
# 如果CONFIG_DIR不存在，则创建并拷贝$QPKG_ROOT/config/config.yaml到CONFIG_DIR
if [ ! -d "$CONFIG_DIR" ]; then
  mkdir -p $CONFIG_DIR
  cp $QPKG_ROOT/config/config.yaml $CONFIG_DIR
fi

https_config(){
	cat>$QPKG_ROOT/config/config.yaml<<-EOF
	bind-addr: 0.0.0.0:5623
	auth: password
	password: codeserver
	cert: /etc/stunnel/stunnel.pem
	cert-key: /etc/stunnel/stunnel.pem
	EOF
}
http_config(){
	cat>$QPKG_ROOT/config/config.yaml<<-EOF
	bind-addr: 0.0.0.0:5623
	auth: password
	password: codeserver
	EOF
}

case "$1" in
	start)
		ENABLED=$(/sbin/getcfg $QPKG_NAME Enable -u -d FALSE -f $CONF)
		if [ "$ENABLED" != "TRUE" ]; then
				echo "$QPKG_NAME is disabled."
				exit 1
		fi
		# create data folder if not exist
		if [ ! -d "$CONFIG_DIR/.code-server" ]; then
			mkdir -p $CONFIG_DIR/.code-server
		fi
		# define config file
		if [ ! -e "$QPKG_ROOT/config/config.yaml" ]; then
			if [ -e "/etc/stunnel/stunnel.pem" ]; then
				https_config
			else
				http_config
			fi
		fi
		# start code-server
		export SERVICE_URL=https://marketplace.visualstudio.com/_apis/public/gallery
		export ITEM_URL=https://marketplace.visualstudio.com/items
		export CODE_SERVER_CONFIG=$QPKG_ROOT/config/config.yaml
		ln -sf $QPKG_ROOT/bin/code-server /usr/local/bin/code-server
		chmod +x $QPKG_ROOT -R
		cd $QPKG_ROOT
		code-server --user-data-dir $CONFIG_DIR/.code-server/ --locale zh-cn --config $CONFIG_DIR/config.yaml &
		;;

	stop)
		#ps ax | grep "entry.js" | grep -v "grep" | awk '{print $1}' | xargs kill
		lsof -i:5623 | awk '{print $2}' > pidfile
		pid=$(awk 'NR==2{print}' pidfile)
		kill "$pid"
		rm -rf pidfile
		rm -rf /usr/local/bin/code-server
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
