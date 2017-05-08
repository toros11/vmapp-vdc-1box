#!/bin/bash

(
    $starting_step "Generate ssh key"
    [[ -f "${private_key}" ]]
    $skip_step_if_already_done ; set -ex
    add_user_key "${internal_user}"
) ; prev_cmd_failed

(
    $starting_step "Configure sshd_config"
    false
    $skip_step_if_already_done ; set -ex
    vm_run_cmd "sed -i \
         -e 's,^PermitRootLogin .*,PermitRootLogin yes,' \
         -e 's,^PasswordAuthentication .*,PasswordAuthentication yes,' \
         -e 's,^DenyUsers.root,#DenyUsers root,' \
         -e 's,^UseDNS yes,UseDNS no,' \
         /etc/ssh/sshd_config"
) ; prev_cmd_failed
