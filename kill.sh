#!/bin/bash

[ -z $ORGCODEDIR ] && ORGCODEDIR="$(cd "$(dirname $(readlink -f "$0"))" && pwd -P)"
export ORGCODEDIR=${ORGCODEDIR}

. ${ORGCODEDIR}/external_libraries/bashsteps/simple-defaults-for-bashsteps.source
. ${ORGCODEDIR}/ind-steps/functions.bash
. ${LINKCODEDIR}/datadir.conf

shutdown
