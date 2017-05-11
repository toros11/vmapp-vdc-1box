#!bin/bash

if [[ -n "${NETWORK}" && -n "${BRIDGE_NAME} " ]] ; then
    create_bridge "${BRIDGE_NAME}" "${NETWORK%.*}.2/24"
    enable_masquerade "${NETWORK}/24"
fi

