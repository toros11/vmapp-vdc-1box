#!/bin/bash
#
# requires: bashsteps
#


VM_USER=
SSH_KEY=
IP_ADDR=
PKG_MGR=

internal_ssh ()
{
    local user="${1:-root}"
    local ip_addr="${IP_ADDR:-2}"
    local ssh_key="${SSH_KEY}"

    [[ -f "${ssh_key}" ]] || return 1
    
    $(type -P ssh) -i "${ssh_key}" -o 'StrictHostKeyChecking=no' -o 'LogLevel=quiet' -o 'UserKnownHostsFile /dev/null' "${user}@${ip_addr}" "${@}"
}

internal_chroot ()
{
    local chroot_path="${1}"

    [[ -d "${chroot_path}" ]] || return 1    
    $(type -P chroot) "${chroot_path}" "${SHELL}" -c "${@}"
}

# Helper function for running commands on nodes so we don't have to make seprate
# scripts for performing the same commands before and after the image is running.
internal_run_cmd ()
{
    local stage="${1:-0}"

    [[ $(get_env_state) -gt $boot ]] && { internal_ssh root@${IP_ADDR} "${@}" ; return $? ; }
    internal_chroot "${@}"
}


# 
internal_install_package ()
{
    local pkg="${1}"
    (
        $starting_step "${vm_name}: install package ${pkg}"
        false
        run_cmd "rpm -q --quiet ${pkg}"
        $skip_step_if_already_done; set -ex
        # "${pkg_mgr:-yum}" install -y "${pkg}"
    ) ; prev_cmd_failed
}

internal_wait_for ()
{
    local service="${step:-service}"
    local condition="${@}"
    local timeout="${timeout:-30}"
    local sleep_time="${sleep_time:-3}"
    local readonly start_time=$(date +%s)

    if ! declare -f get_env_state

    stage=$(get_env_state $stage)
    while :; do
        stage=${stage} internal_run_cmd "${condition}" && return 0
        [[ $(( $(date +%s) - start_time )) -gt $timeout ]] && return 0
        echo "Waiting for ${service}..."
        sleep ${sleep_time}
    done
}
