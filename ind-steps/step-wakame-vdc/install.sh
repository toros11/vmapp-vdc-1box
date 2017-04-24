#!/bin/bash

# for dcmgr
rpm -qi rabbitmq-server || {
    yum install -y http://www.rabbitmq.com/releases/rabbitmq-server/v2.7.1/rabbitmq-server-2.7.1-1.noarch.rpm
}

# for natbox
yum install -y http://dlc.openvnet.axsh.jp/packages/rhel/openvswitch/6.4/openvswitch-2.4.0-1.x86_64.rpm

for pkg_name in ${vdc_package[@]}; do
    install_vdc_package "${pkg_name}"
done

install_vdc_package "${vdc_hypervisor}"
