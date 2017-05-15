#!/bin/bash

hypervisor_setup "${vdc_hypervisor}"

# fluentd plugin
vm_install_package "td-agent-addon-wakame-vdc" || vm_run_cmd "$(rpm -ql td-agent | grep ruby/bin/fluent-gem) install cassandra -v 0.17.0 --no-ri --no-rdoc"
# sta
chkconfig_service "tgtd" "on"

# edge networking
(
    $starting_step "Setup edge networking"
    false
    $skip_step_if_already_done; set -ex
    case "${edge_networking}" in
        "openflow")
            vm_run_cmd "/opt/axsh/wakame-vdc/rpmbuild/helpers/set-openvswitch-conf.sh"
            ;;
        "netfilter") 
	    chkconfig_service "openvswitch" "off" || :
            ;;

    esac
) ; prev_cmd_failed

# bkst-apache
chkconfig_service "httpd" "on"

(
    $starting_step "Set ownership of wakames image storage to apache"
    vm_run_cmd "ls -la /var/lib/wakame-vdc/images | grep apache"
    $skip_step_if_already_done ; set -ex
    vm_run_cmd "chown apache:apache /var/lib/wakame-vdc/images"
) ; prev_cmd_failed
