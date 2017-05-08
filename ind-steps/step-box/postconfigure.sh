#!/bin/bash

# stop services to make post boot configurations
# may not even be required
services=(
    "initctl stop vdc-hva"
    "initctl stop vdc-collector"

    "/etc/init.d/zabbix-server stop"
    "/etc/init.d/zabbix-agent  stop"
    "/etc/init.d/httpd         stop"
)
set -x
for service in "${services[@]}" ; do
    vm_run_cmd "${service}"
done
set +x
