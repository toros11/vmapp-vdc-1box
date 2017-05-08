#!/bin/bash

(
    $starting_step "Download wakame-vdc-stable repository"
    vm_run_cmd "[[ -f /etc/yum.repos.d/wakame-vdc-stable.repo ]]"
    $skip_step_if_already_done ; set -ex
    vm_run_cmd "curl -o /etc/yum.repos.d/wakame-vdc-stable.repo -R https://raw.githubusercontent.com/axsh/wakame-vdc/master/rpmbuild/yum_repositories/wakame-vdc-stable.repo"
) ; prev_cmd_failed

(
    $starting_step "Download openvz repository"
    vm_run_cmd "[[ -f /etc/yum.repos.d/openvz.repo ]]"
    $skip_step_if_already_done ; set -ex
    vm_run_cmd "curl -o /etc/yum.repos.d/openvz.repo -R https://raw.githubusercontent.com/axsh/wakame-vdc/develop/rpmbuild/yum_repositoriesopenvz.repo"
) ; prev_cmd_failed

vm_run_cmd "rpm --import http://download.openvz.org/RPM-GPG-Key-OpenVZ"

  # make into step
vm_run_cmd "yum clean metadata --disablerepo=* --enablerepo=wakame-vdc-rhel6 --enablerepo=wakame-3rd-rhel6"
vm_run_cmd "yum update  -y     --disablerepo=* --enablerepo=wakame-vdc-rhel6 --enablerepo=wakame-3rd-rhel6"


# wakame-vdc-ruby depends on libyaml.
PKG_SRC="http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm" vm_install_package "epel-release"
vm_install_package "libyaml"


# PKG_SRC="http://vault.centos.org/6.9/os/x86_64/Packages/libyaml-0.1.3-1.4.el6.x86_64.rpm"
