#!/bin/bash

umount_box

(
    $starting_step "Start kvm for ${vm_name}"
    kill -0 $(cat "${LINKCODEDIR}/${vm_name}.pid" 2> /dev/null) 2> /dev/null
    $skip_step_if_already_done;
    set -x
    $(cat <<EOS
     qemu-system-x86_64 \
       -machine accel=kvm \
       -cpu ${cpu_type} \
       -m ${mem_size} \
       -smp ${cpu_num} \
       -vnc ${vnc_addr}:${vnc_port} \
       -serial ${serial} \
       -serial pty \
       -drive file=${vm_image},media=disk,if=virtio,format=${format}
       $(
         for (( i=0 ; i < ${#nics[@]} ; i++ )); do
             nic=(${nics[i]})

             case "${nic[0]}" in
                 *"ifname"*)
                     echo -netdev tap,ifname=${nic[0]#*=},script=,downscript=,id=${vm_name}${idx}
                     echo -device virtio-net-pci,netdev=${vm_name}${idx},mac=${nic[1]#*=},bus=pci.0,addr=0x$((3 + ${idx}))
                     ;;
                 *"port"*)
                     echo -net nic,vlan=0,macaddr=${nic[1]#*=},model=virtio,addr=$(( 3 + idx ))
                     echo -net user,vlan=0,hostfwd=tcp::${nic[0]#*=}-:22
                     ;;
             esac
         done
       ) \
       -daemonize \
       -pidfile ${LINKCODEDIR}/${vm_name}.pid
EOS
    )
    set +x
) ; prev_cmd_failed

# No need to attach any nics if we are using user mode networking
[[ "${IP_ADDR}" != "127.0.0.1" ]] && {
    for (( i=0 ; i < ${#nics[@]} ; i++ )) ; do
        nic=(${nics[$i]})

        # Attach tap device to bridge if bridge= was provided
        [[ -z "${nic[2]#*=}" ]] || {
            (
                $starting_step "Attach ${nic[0]#*=} to ${nic[2]#*=}"
                sudo brctl show ${nic[2]#*=} | grep -wq ${nic[0]#*=}
                $skip_step_if_already_done; set -ex
                sudo ip link set ${nic[0]#*=} up
                sudo brctl addif ${nic[2]#*=} ${nic[0]#*=}
            ) ; prev_cmd_failed
        }

        # Set tap device IP adddress if tap_ip_addr= was provided
        [[ -z "${nic[3]#*=}" ]] || {
            (
                ip_addr="${nic[3]#*=}"
                $starting_step "Assign ${ip_addr} to ${nic[0]#*=}"
                ip addr show ${nic[0]#*=} | grep -q ${ip_addr}
                $skip_step_if_already_done; set -x
                sudo ip addr add ${ip_addr} dev ${nic[0]#*=}
                sudo ip link set ${nic[0]#*=} up
            ) ; prev_cmd_failed
        }

        # Set tap device MAC address if tap_hwaddr= was provided
        [[ -z "${nic[4]#*=}" ]] || {
            (
                mac_addr="${nic[4]#*=}"
                $starting_step "Assign ${mac_addr} to ${nic[0]#*=}"
                ip addr show ${nic[0]#*=} | grep -q ${mac_addr}
                $skip_step_if_already_done; set -x
                sudo ip link set dev ${nic[0]#*=} address ${mac_addr}
            ) ; prev_cmd_failed
        }
    done
}
