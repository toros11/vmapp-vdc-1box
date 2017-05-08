#!/bin/bash

  # workaround 2014/10/17
  #
  # in order escape below error
  # > Error: Cannot retrieve metalink for repository: epel. Please verify its path and try again
  #

  # may not be needed anymore
vm_run_cmd "sed -i \
   -e 's,^#baseurl,baseurl,' \
   -e 's,^mirrorlist=,#mirrorlist=,' \
   -e 's,http://download.fedoraproject.org/pub/epel/,http://ftp.jaist.ac.jp/pub/Linux/Fedora/epel/,' \
   /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel-testing.repo"

  # make into step
vm_run_cmd "yum clean metadata --disablerepo=* --enablerepo=wakame-vdc-rhel6 --enablerepo=wakame-3rd-rhel6"
vm_run_cmd "yum update  -y     --disablerepo=* --enablerepo=wakame-vdc-rhel6 --enablerepo=wakame-3rd-rhel6"


# wakame-vdc-ruby depends on libyaml.
PKG_SRC="http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm" vm_install_package "epel-release"
vm_install_package "libyaml"


# PKG_SRC="http://vault.centos.org/6.9/os/x86_64/Packages/libyaml-0.1.3-1.4.el6.x86_64.rpm"
