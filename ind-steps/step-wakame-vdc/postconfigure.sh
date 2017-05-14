#!/bin/bash

# arch specific parameters
case "$(arch)" in
    i686)
        haproxy="wmi-haproxy1d32"
        hva_id="1box32" ;;
    *)
        haproxy="wmi-haproxy1d64"
        hva_id="1box64" ;;
esac

replace_datas=(
#   original value   replace value          file
    "^#NODE_ID=.*"   "NODE_ID=${hva_id}"    "/etc/default/vdc-hva"       # enable hva
    "example.com"    "10.1.0.1"             "/etc/wakame-vdc/dcmgr.conf" # for load balancer
    "wmi-demolb"     "${haproxy}"           "/etc/wakame-vdc/dcmgr.conf" # for load balancer
    "bkst-local"     "bkst-demo3"           "/etc/wakame-vdc/dcmgr.conf" # overwrite default 
)

replace_pattern "${replace_datas[@]}"

# prepare vdc services
for file in $(vm_run_cmd "ls /etc/default/vdc-*") ; do
    replace_pattern "^#RUN=.*" "RUN=yes" "${file}"
done

(
    $staring_step "Start mysql"
    vm_run_cmd "service mysqld status | grep -q running"
    $skip_step_if_already_done; set -ex
    vm_run_cmd "service mysqld start"
) ; prev_cmd_failed


for dbname in wakame_dcmgr wakame_dcmgr_gui zabbix; do
    (
        $starting_step "Create databases"
        vm_run_cmd "mysql <<< \"show databases;\" | grep ${dbname}"
        $skip_step_if_already_done ; set -x
        # zabbix should possibly be moved to the zabbix post configure script
        # vm_run_cmd "yes | mysqladmin -uroot drop ${dbname}" || :
        vm_run_cmd "mysqladmin -uroot create ${dbname} --default-character-set=utf8"
    ) ; prev_cmd_failed
done

for dirpath in /opt/axsh/wakame-vdc/dcmgr /opt/axsh/wakame-vdc/frontend/dcmgr_gui; do
    (
        $starting_step "Initialize databases"
        false
        $skip_step_if_already_done ; set -ex
        vm_run_cmd "( cd ${dirpath} ; /opt/axsh/wakame-vdc/ruby/bin/bundle exec rake db:init --trace )"
    ) ; prev_cmd_failed
done

# TODO: check wether we need this or not
# export HOME=/root

vm_run_cmd "find /var/lib/wakame-vdc/demo/vdc-manage.d/ -type f | sort | xargs cat | egrep -v '^#|^$' | /opt/axsh/wakame-vdc/dcmgr/bin/vdc-manage"
vm_run_cmd "find /var/lib/wakame-vdc/demo/gui-manage.d/ -type f | sort | xargs cat | egrep -v '^#|^$' | /opt/axsh/wakame-vdc/frontend/dcmgr_gui/bin/gui-manage"
