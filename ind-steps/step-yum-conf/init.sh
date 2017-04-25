#!/bin/bash

# # is this needed ?
# (
#     $starting_script ""
# chroot $1 $SHELL -ex <<EOS
#   cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.saved
#   sed 's,^#baseurl=.*,baseurl=${baseurl},' /etc/yum.repos.d/CentOS-Base.repo.saved \
#    | sed -n '1,/^\[updates\]/p' \
#    | egrep -v  "^\[updates\]" > /etc/yum.repos.d/CentOS-Base.repo
#   sed -i 's,^mirrorlist,#mirrorlist,' /etc/yum.repos.d/CentOS-Base.repo
# EOS
