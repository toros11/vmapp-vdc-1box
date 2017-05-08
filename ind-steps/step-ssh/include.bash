#!/bin/bash

# default values, override in datadir.conf for custom values
internal_user="${internal_user:-root}"
keys_path="/home/${USER}/.ssh/keys"
private_key="${SSH_KEY:-/home/${USER}/.ssh/keys/${internal_user}@${vm_name}}"
public_key="${private_key}.pub"

add_user_key ()
{
    local user="${1}"

    mkdir -p "${keys_path}"
    ssh-keygen -t rsa -b 2048 -N "" -f "${private_key}"
    chmod 600 "${private_key}"
    chmod 600 "${public_key}"

    if [[ "${internal_user}" == "root" ]]; then
        vm_run_cmd "mkdir -p -m 700 /root/.ssh"
        sudo mv "${public_key}" "${TMP_ROOT}/root/.ssh/authorized_keys"
    else
        vm_run_cmd "adduser ${internal_user}" || :
        vm_run_cmd "mkdir -p -m 600 /home/${internal_user}/.ssh"
        sudo mv "${public_key}" "${TMP_ROOT}/home/${internal_user}/.ssh/authorized_keys"
    fi
}

