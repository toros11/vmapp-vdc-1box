#!/bin/bash

# bridge/network is individual for each node
create_bridge "${BRIDGE_NAME}" "${NETWORK%.*}.2/24"
enable_masquerade "${NETWORK}/24"

if mount | grep -q "${TMP_ROOT}" ; then
    (
        $starting_step "${vm_name}: Unmount temporary root folder for ${vm_name}"
        ! mount | grep -qw "${TMP_ROOT}" || [[ ! -d "${TMP_ROOT}" ]]
        $skip_step_if_already_done;
        umount-partition --sudo "${TMP_ROOT}"
    ) ; prev_cmd_failed
fi

(
    $starting_step "${vm_name}: deploy image"
    [[ -f "${vm_image}" ]]
    $skip_step_if_already_done ; set -e
    tar -Sxzf "${ORGCODEDIR}/${seed_image}" -C "${LINKCODEDIR}"
    rm -f "${LINKCODEDIR}/box-disk1.rpm-qa"
) ; prev_cmd_failed

(
    $starting_step "${vm_name}: mount ${seed_image}"
    mount | grep -q "${TMP_ROOT}"
    $skip_step_if_already_done
    mkdir -p "${TMP_ROOT}"
    mount-partition --sudo "${vm_image}" 1 "${TMP_ROOT}"
) ; prev_cmd_failed

(
    $starting_step "Synching guestroot for ${vm_name}"
    false
    $skip_step_if_already_done; set -ex
    sudo rsync -rv "${LINKCODEDIR}/guestroot/"                           "${TMP_ROOT}"
    sudo rsync -rv "${LINKCODEDIR}/guestroot.${edge_networking}/"        "${TMP_ROOT}"
    sudo rsync -rv "${LINKCODEDIR}/guestroot.${edge_networking}.nictab/" "${TMP_ROOT}"
    sudo rsync -rv "${LINKCODEDIR}/guestroot.${vdc_hypervisor}/"         "${TMP_ROOT}"
    sudo rsync -rv "${LINKCODEDIR}/guestroot.${vdc_hypervisor}.${arch}/" "${TMP_ROOT}"

) ; prev_cmd_failed

# the tap device used to access the 1box
(
    $starting_step "Render network config"
    vm_run_cmd "[[ -f /etc/sysconfig/network-scripts/ifcfg-onebox ]]"
    $skip_step_if_already_done ; set -ex
    vm_run_cmd "cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-onebox-${idx}
DEVICE=onebox-${idx}
ONBOOT=yes
TYPE=Ethernet
BOOTPROTO=static
IPADDR=${IP_ADDR}
NETMASK=255.255.255.0
EOF
"
) ; prev_cmd_failed
