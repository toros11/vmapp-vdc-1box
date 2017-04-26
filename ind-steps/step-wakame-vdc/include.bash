#!/bin/bash

hypervisor_setup () 
{
    local hypervisor="${1}"

    (
        $starting_step "Setup load balancer"
        false
        $skip_step_if_already_done ; set -ex
        vm_run_cmd "[ -f /etc/wakame-vdc/convert_specs/load_balancer.yml ]" &&
            vm_run_cmd "sed -i \"s,hypervisor: .*,hypervisor: 'dummy',\" /etc/wakame-vdc/convert_specs/load_balancer.yml"
    ) ; prev_cmd_failed

    (
        $starting_step "Setup hypervisor: ${vdc_hypervisor}"
        false
        $skip_step_if_already_done ; set -ex
        case "${vdc_hypervisor}" in 
            "openvz")
                vm_run_cmd "/opt/axsh/wakame-vdc/rpmbuild/helpers/edit-grub4vz.sh add"
                vm_run_cmd "/opt/axsh/wakame-vdc/rpmbuild/helpers/edit-grub4vz.sh enable" ;;
            "lxc")
                vm_run_cmd "echo none                    /cgroup                 cgroup  defaults        0 0 >> /etc/fstab"
                vm_run_cmd "[[ -d /var/lib/lxc ]] || mkdir /var/lib/lxc" ;;
            *)
                return 0 ;;
        esac
    ) ; prev_cmd_failed
}

install_vdc_package ()
{
    local pkg_name="${1}"
    if declare -f setup_"${pkg_name}" > /dev_null ; then
        setup_"${pkg_name}"
    fi
    pkg_name="wakame-vdc-${pkg_name}-vmapp-config"
    (
        $starting_step "Install vdc-package ${pkg_name}"
        vm_run_cmd "yum search --enablerepo=wakame-vdc-rhel6 --enablerepo=wakame-3rd-rhel6 ${pkg_name} | egrep -q ${pkg_name}"
        $skip_step_if_already_done ; set -ex
        vm_run_cmd "yum install --enablerepo=wakame-vdc-rhel6 --enablerepo=wakame-3rd-rhel6 -y ${pkg_name}"
    ) ; prev_cmd_failed
}

# package dependencies

setup_dcmgr () 
{
    PKG_SRC="http://www.rabbitmq.com/releases/rabbitmq-server/v2.7.1/rabbitmq-server-2.7.1-1.noarch.rpm" install_package "rabbitmq-server"
}

setup_natbox () 
{
    PKG_SRC="http://dlc.openvnet.axsh.jp/packages/rhel/openvswitch/6.4/openvswitch-2.4.0-1.x86_64.rpm" install_package "openvswtich-2.4.0"
}
