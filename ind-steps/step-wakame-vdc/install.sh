#!/bin/bash

for pkg_name in ${vdc_package[@]}; do
    install_vdc_package "${pkg_name}"
done
