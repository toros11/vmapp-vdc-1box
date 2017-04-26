#!/bin/bash

#### zabbix

# mysql -uroot <<'EOS'
#   grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix';
#   flush privileges;
# EOS


##### zabbix-server 1.8

# while read line; do
#   # [2014/08/21] disable zabbix db import
#   echo "mysql -uroot zabbix < ${line}"
# done < <(
#   rpm -ql zabbix-server-mysql | grep schema/mysql.sql
#   rpm -ql zabbix-server-mysql | egrep '/data/.*\.sql$'
# )
