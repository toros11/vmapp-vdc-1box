#!/bin/bash

openvz_setup ()
{
    # bashsteps run_cmd
    /opt/axsh/wakame-vdc/rpmbuild/helpers/edit-grub4vz.sh add
    /opt/axsh/wakame-vdc/rpmbuild/helpers/edit-grub4vz.sh enable

}

lxc_setup ()
{
    # bashsteps run_cmd
    echo "none                    /cgroup                 cgroup  defaults        0 0" >> /etc/fstab
    [[ -d /var/lib/lxc ]] || mkdir /var/lib/lxc
}


hypervisor_setup () 
{
    if [ -f /etc/wakame-vdc/convert_specs/load_balancer.yml ]; then
	sed -i "s,hypervisor: .*,hypervisor: 'dummy'," /etc/wakame-vdc/convert_specs/load_balancer.yml
    fi
    
    case "${hypervisor}" in 
	"openvz"|"lxc")
	    ${hypervisor}_setup ;;
    esac
}

install_vdc_package ()
{
    local pkg_name="${1}"
    yum search --enablerepo=wakame-vdc-rhel6 --enablerepo=wakame-3rd-rhel6 ${pkg_name} | egrep -q ${pkg_name} || continue
    yum install --enablerepo=wakame-vdc-rhel6 --enablerepo=wakame-3rd-rhel6 -y ${pkg_name}
}

# rename functions or parse variable in install_vdc_package
setup_dcmgr () 
{
    # for dcmgr
    rpm -qi rabbitmq-server || yum install -y http://www.rabbitmq.com/releases/rabbitmq-server/v2.7.1/rabbitmq-server-2.7.1-1.noarch.rpm
}

setup_natbox () 
{
    # for natbox
    yum install -y http://dlc.openvnet.axsh.jp/packages/rhel/openvswitch/6.4/openvswitch-2.4.0-1.x86_64.rpm
}
