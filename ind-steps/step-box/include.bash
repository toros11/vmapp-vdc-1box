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
        ! mount | grep -qw "${TMP_ROOT}" || [[ ! -d "${TMP_ROOT}" ]] || [[ "${format}" != "qcow2" ]]
	false
        $skip_step_if_already_done;
        umount_img
        rm -rf "${TMP_ROOT}"
    ) ; prev_cmd_failed
}

destroy_box ()
{
    [[ $stage -lt $boot ]] && umount_box || shutdown
    (
        $starting_step "${vm_name}: delete seed image"
        [[ ! -f "${VM_IMAGE}" ]]
        $skip_step_if_already_done; set -ex
        rm -f "${VM_IMAGE}"
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


build_hostfwd_param()
{
    local ret_val="hostfwd=tcp::${ACCESS_PORT}-:22"

    for port in ${extra_port_forward[@]} ; do
        ret_val="${ret_val},hostfwd=tcp::$(( port + 10000 + idx ))-:${port}"
    done
    echo "${ret_val}"
}

build_nic_param()
{
    for (( i=0 ; i < ${#nics[@]} ; i++ )); do
        nic=(${nics[i]})

        if [[ -z ${ACCESS_PORT} ]] ; then
            echo "-netdev tap,ifname=${nic[0]#*=},script=,downscript=,id=${vm_name}${idx} -device virtio-net-pci,netdev=${vm_name}${idx},mac=${nic[1]#*=},bus=pci.0,addr=0x$((3 + ${idx}))"
        else
            hostfwd="$(build_hostfwd_param)"

            echo "-net nic,vlan=0,macaddr=${nic[0]#*=},model=virtio,addr=$(( 3 + idx )) -net user,vlan=0,${hostfwd}"
            break
        fi
    done
}

build_qemu_cmd()
{
    cat <<EOF > ${LINKCODEDIR}/.kvm.cmd
qemu-system-x86_64 \
-machine accel=kvm \
-cpu ${cpu_type} \
-m ${mem_size} \
-smp ${cpu_num} \
-vnc ${vnc_addr}:${vnc_port} \
-serial ${serial} \
-serial pty \
-drive file=${VM_IMAGE},media=disk,if=virtio,format=${format} \
$(build_nic_param) \
-daemonize \
-pidfile ${LINKCODEDIR}/${vm_name}.pid
EOF

}
