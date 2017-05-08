
chkconfig_service "zabbix-server" "on"

vm_run_cmd "cat <<EOF > $1/etc/php.d/zabbix.ini
[PHP]
post_max_size = 32M
upload_max_filesize = 16M
max_execution_time = 600
xmax_input_time = 600
[Date]
date.timezone = $(date '+%Z')
EOF"
) ; prev_cmd_failed

(
    $starting_step "Update my.cnf"
    vm_run_cmd "grep -q 'bind-address = 127.0.0.1' /etc/my.cnf"
    $skip_step_if_already_done ; set -ex
    vm_run_cmd "cat <<EOF >> /etc/my.cnf
[mysqld]
bind-address = 127.0.0.1
default-character-set=utf8
skip-character-set-client-handshake
EOF"

) ; prev_cmd_failed

chkconfig_service "zabbix-agent" "on"
