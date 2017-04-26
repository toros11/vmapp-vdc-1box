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

cfg_tbl=(
#   original value   replace value          file
    "^#NODE_ID="     "NODE_ID=${hva_id}"    "/etc/default/vdc-hva"       # enable hva
    "^#RUN=.*"       "RUN=yes"              "/etc/default/vdc-*"         # prepare vdc services
    "example.com"    "10.1.0.1"             "/etc/wakame-vdc/dcmgr.conf" # for load balancer
    "wmi-demolb"     "${haproxy}"           "/etc/wakame-vdc/dcmgr.conf" # for load balancer
    "bkst-local"     "bkst-demo3"           "/etc/wakame-vdc/dcmgr.conf" # overwrite default 
)

(
    for (( i=0 ; i < ${#cfg_tbl[@]}; i+=3 )) ; do
        orig="${cfg_tbl[i]}"
        repl="${cfg_tbl[((i+1))]}"
        file="${cfg_tbl[((i+2))]}"

        $starting_step "Replace value in ${file}"
        vm_cmd_run "grep ${repl} ${file}"
        $skip_step_if_already_done ; set -ex
        vm_cmd_run "sed -i -e \"s,${orig},${repl},g\" ${file}"
    done
) ; prev_cmd_failed

(
    $starting_step "Create databases"
    false
    $skip_step_if_already_done ; set -ex
    # zabbix should possibly be moved to the zabbix post configure script
    for dbname in wakame_dcmgr wakame_dcmgr_gui zabbix dolphin; do
      vm_run_cmd "yes | mysqladmin -uroot drop ${dbname}"
      vm_run_cmd "mysqladmin -uroot create ${dbname} --default-character-set=utf8"
    done
) ; prev_cmd_failed

(
    $starting_step "Initialize databases"
    false
    $skip_step_if_already_done ; set -ex
    for dirpath in /opt/axsh/wakame-vdc/dcmgr /opt/axsh/wakame-vdc/frontend/dcmgr_gui; do
        vm_run_cmd "( cd ${dirpath} ; /opt/axsh/wakame-vdc/ruby/bin/bundle exec rake db:init --trace )"
    done
) ; perv_cmd_failed

# TODO: check wether we need this or not
# export HOME=/root

vm_run_cmd "find /var/lib/wakame-vdc/demo/vdc-manage.d/ -type f | sort | xargs cat | egrep -v '^#|^$' | /opt/axsh/wakame-vdc/dcmgr/bin/vdc-manage"
vm_run_cmd "find /var/lib/wakame-vdc/demo/gui-manage.d/ -type f | sort | xargs cat | egrep -v '^#|^$' | /opt/axsh/wakame-vdc/frontend/dcmgr_gui/bin/gui-manage"
