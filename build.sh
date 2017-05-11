#!/bin/bash

[[ -z $ORGCODEDIR ]] && ORGCODEDIR="$(cd "$(dirname $(readlink -f "$0"))" && pwd -P)"
. ${ORGCODEDIR}/external_libraries/bashsteps/simple-defaults-for-bashsteps.source
export ORGCODEDIR

. ${ORGCODEDIR}/ind-steps/functions.bash
. ${LINKCODEDIR}/datadir.conf "${1:-0}" # optional parameter for indexing multiple nodes

cat <<EOF

=======> building $LEVEL:

EOF

execute $(get_build_state $stage) $(cat ${LINKCODEDIR}/steplist.conf)

cat <<EOF

<======= finished building $LEVEL

EOF
