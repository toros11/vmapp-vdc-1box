#!/bin/bash

if mount | grep -q "${TMP_ROOT}" ; then
    (
        $starting_step "${vm_name}: Unmount temporary root folder for ${vm_name}"
        ! mount | grep -qw "${TMP_ROOT}" || [[ ! -d "${TMP_ROOT}" ]]
        $skip_step_if_already_done;
        umount_box
    ) ; prev_cmd_failed
fi

(
    $starting_step "${vm_name}: deploy image"
    [[ -f "${VM_IMAGE}" ]]
    $skip_step_if_already_done ; set -e
    tar -Sxzf "${ORGCODEDIR}/${seed_image}" -C "${LINKCODEDIR}"
    rm -f "${LINKCODEDIR}/box-disk1.rpm-qa"
) ; prev_cmd_failed

(
    $starting_step "${vm_name}: mount ${seed_image}"
    mount | grep -q "${TMP_ROOT}"
    $skip_step_if_already_done
    mkdir -p "${TMP_ROOT}"
    mount_img
) ; prev_cmd_failed

${LINKCODEDIR}/prepare-vmimage.sh "${vdc_hypervisor}" "${arch}"
${LINKCODEDIR}/gen-vmcmdset.sh "${vdc_hypervisor}" "${arch}"

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

# 127.0.0.1 means we are using user mode networking and we don't need to replace anything
[[ "${IP_ADDR}" != "127.0.0.1" ]] && {
    # the default ip address is set to 10.0.2.15, we need toreplace it with the one assigned
    # if we setup a tap device.
    replace_datas=(
    #   original value  replace valueu  file
	"10.0.2.15"     "${IP_ADDR}"    "/home/centos/.musselrc"                   # mussel
	"10.0.2.15"     "${IP_ADDR}"    "/etc/wakame-vdc/hva.conf"                 # hva
	"10.0.2.15"     "${IP_ADDR}"    "/etc/sysconfig/network-scripts/ifcfg-br0" # nic
    )
    replace_pattern "${replace_datas[@]}"
}
