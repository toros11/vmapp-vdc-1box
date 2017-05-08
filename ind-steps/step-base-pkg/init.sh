#!/bin/bash

for pkg in ${include_packages[@]} ; do
    vm_install_package "${pkg}"
done
