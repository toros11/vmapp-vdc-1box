#!/bin/bash

for pkg_name in ${vdc_package[@]}; do
    install_vdc_package "${pkg_name}"
done

vm_install_package "wakame-vdc-client-mussel"
vm_install_package "bash-completion"
install_vdc_package "hva-${vdc_hypervisor}"
