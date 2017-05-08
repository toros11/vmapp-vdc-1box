#!/bin/bash

for pkg in ${zabbix_package[@]} ; do
    vm_install_package "${pkg}-${zabbix_version}"
done
