#!/bin/bash

#### zabbix

vm_run_cmd "mysql -uroot <<< \"grant all privileges on zabbix.* to zabbix@localhost identified by 'zabbix'; flush privileges;\""

##### zabbix-server 1.8

while read line; do
  # [2014/08/21] disable zabbix db import
  vm_run_cmd "mysql -uroot zabbix < ${line}"
done < <(
  vm_run_cmd "rpm -ql zabbix-server-mysql | grep schema/mysql.sql"
  vm_run_cmd "rpm -ql zabbix-server-mysql | egrep '/data/.*\.sql$'"
)
