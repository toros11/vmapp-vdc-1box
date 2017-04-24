#!/bin/bash

mount_osx ()
{
    local image="${1}"
    local mount_path="${2}"
    local device="$(hdiutil attach -imagekey diskimage-class=CRawDiskImage -nomount "${image}" | grep Linux | awk '{ print $1 }')"
    sudo fuse-ext2 "${device}" "${mount_path}" -o rw+,force

    echo "${device}"
}

umount_osx ()
{
    local mount_path="${1}"
    local device="${2}"

    sudo umount -f "${mount_path}"
    hdiutil detach "${device}"
}
