#!bin/bash

create_bridge "${BRIDGE_NAME}" "${NETWORK%.*}.2/24"
enable_masquerade "${NETWORK}/24"

