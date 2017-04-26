
# stop services to make post boot configurations

vm_run_cmd $(cat <<EOF

initctl stop vdc-hva
initctl stop vdc-collector

/etc/init.d/zabbix-server stop
/etc/init.d/zabbix-agent  stop
/etc/init.d/httpd         stop

EOF

