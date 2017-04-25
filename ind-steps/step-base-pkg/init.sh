#!/bin/bash

# make into bashstep
for pkg in ${include_packages[@]} ; do
    install_package "${pkg}"
done
