#1/bin/bash

check_dependency ()
{
    local pkg="${1}"
    command -v "${pkg}" >/dev/null 2>&1 || {
        echo "Missing dependency: ${pkg}"
        exit 255
    }
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
}

shutdown_buildenv ()
{
    return
}
