#!/bin/bash
#
# requires:
#  bash
#
set -e

## functions

### validation

function valid_cmd?() {
  local cmd=$1

  case "${cmd}" in
  build|start|stop|dist|raw2vdi|raw2vmdk)
    ;;
  *)
    echo "[ERROR] unknown cmd: ${cmd} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2
    return 1
  esac
}

function valid_hypervisor?() {
  local hypervisor=$1

  case "${hypervisor}" in
  lxc|openvz|kvm)
    ;;
  *)
   echo "[ERROR] unknown hypervisor: ${hypervisor} (${BASH_SOURCE[0]##*/}:${LINENO})" >&2
   return 1
   ;;
  esac
}

### box

function build_box() {
  local hypervisor=$1
  [[ -n "${hypervisor}" ]] || { echo "[ERROR] invalid parameter (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  valid_hypervisor? ${hypervisor} || return 1

  local arch_type
  case "$(arch)" in
    i686) arch_type=32 ;;
  x86_64) arch_type=64 ;;
  esac

  make ${hypervisor}${arch_type}.${VDC_EDGE_NETWORKING:-netfilter}
}

function start_box() {
  local hypervisor=$1
  [[ -n "${hypervisor}" ]] || { echo "[ERROR] invalid parameter (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  valid_hypervisor? ${hypervisor} || return 1

  sudo ./vmbuilder/kvm/rhel/6/misc/kvm-ctl.sh start \
   --vnc-port     ${vnc_port} \
   --vif-num      ${vif_num}  \
   --mem-size     ${mem_size} \
   --cpu-num      ${cpu_num}  \
   --brname       ${brname}   \
   --monitor-port ${monitor_port} \
   --serial-port  ${serial_port}  \
   --image-path   ./1box-${hypervisor}.netfilter.$(arch).raw
}

function stop_box() {
  local hypervisor=$1
  [[ -n "${hypervisor}" ]] || { echo "[ERROR] invalid parameter (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  valid_hypervisor? ${hypervisor} || return 1

  echo quit | nc localhost ${monitor_port}
}

function dist_box() {
  local hypervisor=$1
  [[ -n "${hypervisor}" ]] || { echo "[ERROR] invalid parameter (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  valid_hypervisor? ${hypervisor} || return 1

  local image_path=./1box-${hypervisor}.netfilter.$(arch).raw
  time tar zScvpf ${image_path}.tar.gz ${image_path}
}


function raw2vdi_box() {
  local hypervisor=$1
  [[ -n "${hypervisor}" ]] || { echo "[ERROR] invalid parameter (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  valid_hypervisor? ${hypervisor} || return 1

  local image_path=./1box-${hypervisor}.netfilter.$(arch).raw
  time ./vmbuilder/kvm/rhel/6/misc/raw2vdi.sh ${image_path}
}

function raw2vmdk_box() {
  local hypervisor=$1
  [[ -n "${hypervisor}" ]] || { echo "[ERROR] invalid parameter (${BASH_SOURCE[0]##*/}:${LINENO})" >&2; return 1; }
  valid_hypervisor? ${hypervisor} || return 1

  local image_path=./1box-${hypervisor}.netfilter.$(arch).raw
  time ./vmbuilder/kvm/rhel/6/misc/raw2vmdk.sh ${image_path}
}

## variables

### this script

declare cmd=${1:?"[ERROR] invalid parameter (${BASH_SOURCE[0]##*/}:${LINENO})"}
declare hypervisor=${2:?"[ERROR] invalid parameter (${BASH_SOURCE[0]##*/}:${LINENO})"}

### kvm-ctl.sh

monitor_port=${monitor_port:-4444}
vnc_port=${vnc_port:-1002}
serial_port=${serial_port:-5555}
vif_num=${vif_num:-2}
mem_size=${mem_size:-2048}
cpu_num=${cpu_num:-4}
brname=${brname:-vboxbr0}

## validate

valid_hypervisor? ${hypervisor} || exit 1
valid_cmd? ${cmd} || exit 1

## main

${cmd}_box ${hypervisor}
