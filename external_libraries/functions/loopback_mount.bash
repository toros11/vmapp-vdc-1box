#!/bin/bash
format="${1:-raw}"

if [[ ${format} == "raw" ]] ; then
    # include mount-partition
    . "${ORGCODEDIR}/external_libraries/mount-partition/mount-partition.sh" "load"
fi

mount_img ()
{
    : "${TMP_ROOT:?"should be defined"}"
    : "${VM_IMAGE:?"should be defined"}"

    case ${format} in
	raw) mount-partition --sudo "${VM_IMAGE}" 1 "${TMP_ROOT}" ;;
	qcow2) # images made by packer comes as lvm2 volumes and therfore needs to be setup from device mapper
	    sudo qemu-nbd -c /dev/nbd0 ${VM_IMAGE}
	    lvm_disk=$(sudo lvmdiskscan | grep "/dev" | grep "LVM" | awk '{ print $1 }')
	    sudo vgchange -a y
	    vol_group="$(sudo vgdisplay | grep 'VG Name' | awk '{ print $3 }')"
	    sudo mount "/dev/mapper/${vol_group}-lv_root" ${TMP_ROOT}
	    ;;
    esac
}

umount_img () 
{
    case ${format} in
	raw) umount-partition --sudo "${TMP_ROOT}" ;;
	qcow2) 
	    set -x
	    sudo umount ${TMP_ROOT} || :
	    sudo qemu-nbd -d /dev/nbd0
	    vol_group="$(sudo vgdisplay | grep 'VG Name' | awk '{ print $3 }')"
	    vgchange -an ${vol_group}
	    set +x
	    ;;
    esac
}
