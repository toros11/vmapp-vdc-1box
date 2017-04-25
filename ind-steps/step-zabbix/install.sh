#!/bin/bash


for pkg in ${zabbix_package[@]} ; do
    install_package "${pkg}${zabbix_version}"
done
