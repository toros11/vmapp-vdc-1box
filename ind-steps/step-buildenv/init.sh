#!/bin/bash

for dep in "${DEPENDENCIES[@]}" ; do
    check_dependency "${dep}"
done

(
    $starting_step "Environment: download seed image"
    [ -f "${ORGCODEDIR}/${seed_image}" ]
    $skip_step_if_already_done
    curl -o "${ORGCODEDIR}/${seed_image}" -O "https://ci.openvdc.org/img/${seed_image}"
    $skip_step_if_already_done ; set -ex
) ; prev_cmd_failed

