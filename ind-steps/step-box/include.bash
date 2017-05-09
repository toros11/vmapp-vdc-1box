#!/bin/bash

shutdown_box ()
{
    (
        $starting_step "${vm_name}: killing vm"
        [[ ! -f "${LINKCODEDIR}/${vm_name}.pid" ]]
        $skip_step_if_already_done; set -ex
        kill $(cat "${LINKCODEDIR}/${vm_name}.pid") 2> /dev/null
        rm -f "${LINKCODEDIR}/${vm_name}.pid"
        rm -f ${LINKCODEDIR}/.state
    ) ; prev_cmd_failed
}

umount_box ()
{
    (
        $starting_step "${vm_name}: Unmount temporary root folder for ${vm_name}"
        ! mount | grep -qw "${TMP_ROOT}" || [[ ! -d "${TMP_ROOT}" ]]
        $skip_step_if_already_done;
        umount-partition --sudo "${TMP_ROOT}"
        rm -rf "${TMP_ROOT}"
    ) ; prev_cmd_failed
}

destroy_box ()
{
    [[ $stage -lt $boot ]] && umount_box || shutdown
    (
        $starting_step "${vm_name}: delete seed image"
        [[ ! -f "${vm_image}" ]]
        $skip_step_if_already_done; set -ex
        rm -f "${vm_image}"
    ) ; prev_cmd_failed

    (
        key="${SSH_KEY:-/home/${USER}/.ssh/keys/${internal_user:-root}@${vm_name}}"
        $starting_step "${vm_name}: delete private ssh key"
        [[ ! -f "${key}" ]]
        $skip_step_if_already_done ; set -ex
        rm -f "${key}"
    ) ; prev_cmd_failed

    rm -f ${LINKCODEDIR}/.state
}
