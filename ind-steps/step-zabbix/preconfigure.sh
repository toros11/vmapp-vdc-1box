
chkconfig_service "zabbix-server" "on"

vm_run_cmd "cat <<EOF > $1/etc/php.d/zabbix.ini
[PHP]
post_max_size = 32M
upload_max_filesize = 16M
max_execution_time = 600
xmax_input_time = 600
[Date]
date.timezone = $(date '+%Z')
EOF"

vm_run_cmd "cat <<EOF >> $1/etc/my.cnf
[mysqld]
bind-address = 127.0.0.1
default-character-set=utf8
skip-character-set-client-handshake
EOF"


# chroot $1 $SHELL -ex -ex <<EOS
#   chkconfig --list zabbix-agent
#  #chkconfig zabbix-agent on
# EOS
