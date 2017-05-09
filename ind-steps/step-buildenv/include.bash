#1/bin/bash

check_dependency ()
{
    local pkg="${1}"
    command -v "${pkg}" >/dev/null 2>&1 || {
        echo "Missing dependency: ${pkg}"
        exit 255
    }
}

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


destroy_buildenv ()
{
    for node in ${NODES[@]} ; do
        (
            $starting_group "Environment: destroy ${node}"
            false
            $skip_group_if_unnecessary
            "${ORGCODEDIR}/nodes/${node}/destroy.sh"
        ) ; prev_cmd_failed
    done
    rm -f ${ORGCODEDIR}/.state
    remove_bridge "${BRIDGE_NAME}"
    disable_masquerade "${NETWORK}/24"
}

shutdown_buildenv ()
{
    for node in ${NODES[@]} ; do
        (
            $starting_group "Environment: kill ${node}"
            false
            $skip_group_if_unnecessary
            "${ORGCODEDIR}/nodes/${node}/kill.sh"
        ) ; prev_cmd_failed
    done
    rm -f ${ORGCODEDIR}/.state
    remove_bridge "${BRIDGE_NAME}"
    disable_masquerade "${NETWORK}/24"
}
