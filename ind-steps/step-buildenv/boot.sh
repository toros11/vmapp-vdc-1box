#!/bin/bash

(
    idx=0
    for node in ${NODES[@]} ; do
        $starting_group "Environment: building ${node}"
        false
        $skip_group_if_unnecessary
        "${ORGCODEDIR}/nodes/${node}/build.sh" "${idx}" &> "${ORGCODEDIR}/nodes/${node}/build.log"
        idx=$(( idx + 1 ))
        node_build_pid[$!]="${node}"
    done
) ; prev_cmd_failed
