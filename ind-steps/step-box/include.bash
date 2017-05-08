#!/bin/bash

create_bridge ()
{
    local br_name="${1}"
    local ip_addr="${2}"
    (
        $starting_step "${vm_name}: create bridge ${br_name} ${ip_addr}"
        brctl show | grep -q "${br_name}"
        $skip_step_if_already_done ; set -ex
        sudo brctl addbr "${br_name}"
        sudo ip link set "${br_name}" up

        [[ -n "${ip_addr}" ]] && sudo ip addr add "${ip_addr}" dev "${br_name}"
    ) ; prev_cmd_failed
}

remove_bridge ()
{
    local br_name="${1}"
    (
        $starting_step "${vm_name}: remove bridge ${bridge}"
        ! brctl show | grep -q "${br_name}"
        $skip_step_if_already_done ; set -ex
        sudo ip link set "${br_name}" down
        sudo brctl delbr "${br_name}"
    ) ; prev_cmd_failed
}

enable_masquerade ()
{
    local subnet="${1}"
    (
        $starting_step "${vm_name}: enable masquerade on ${subnet}"
        sudo iptables-save | grep -wq "\-A POSTROUTING \-s ${subnet} \-j MASQUERADE"
        $skip_step_if_already_done ; set -ex
        sudo iptables -t nat -A POSTROUTING -s "${subnet}" -j MASQUERADE
    ) ; prev_cmd_failed
}

disable_masquerade ()
{
    local subnet="${1}"
    (
        $starting_step "${vm_name}: disable masquerade on ${subnet}"
        ! sudo iptables-save | grep -wq "\-A POSTROUTING \-s ${subnet} \-j MASQUERADE"
        $skip_step_if_already_done ; set -ex
        sudo iptables -t nat -D POSTROUTING -s "${subnet}" -j MASQUERADE
    ) ; prev_cmd_failed
}

shutdown_box ()
{
    (
        $starting_step "${vm_name}: killing vm"
        [[ ! -f "${LINKCODEDIR}/${vm_name}.pid" ]]
        $skip_step_if_already_done; set -ex
        kill $(cat "${LINKCODEDIR}/${vm_name}.pid") 2> /dev/null
        rm -f "${LINKCODEDIR}/${vm_name}.pid"
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
    remove_bridge "${BRIDGE_NAME}"
    disable_masquerade "${NETWORK}/24"
}
