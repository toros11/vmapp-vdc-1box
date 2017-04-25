#!/bin/bash

  # workaround 2014/10/17
  #
  # in order escape below error
  # > Error: Cannot retrieve metalink for repository: epel. Please verify its path and try again
  #

  # make into step
vm_run_cmd "sed -i \
   -e 's,^#baseurl,baseurl,' \
   -e 's,^mirrorlist=,#mirrorlist=,' \
   -e 's,http://download.fedoraproject.org/pub/epel/,http://ftp.jaist.ac.jp/pub/Linux/Fedora/epel/,' \
   /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel-testing.repo"

  # make into step
vm_run_cmd "yum clean metadata --disablerepo=* --enablerepo=wakame-vdc-rhel6 --enablerepo=wakame-3rd-rhel6"
vm_run_cmd "yum update  -y     --disablerepo=* --enablerepo=wakame-vdc-rhel6 --enablerepo=wakame-3rd-rhel6"


# make into step

# wakame-vdc-ruby depends on libyaml.
# TODO: handle arch type.

vm_run_cmd "yum install -y http://vault.centos.org/6.6/os/x86_64/Packages/libyaml-0.1.3-1.4.el6.x86_64.rpm"
