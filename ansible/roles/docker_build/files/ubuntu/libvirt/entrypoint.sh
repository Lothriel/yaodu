#!/bin/bash

set -o errexit

source /opt/yaodu/common.sh

main() {
    initial_setup

    if [[ $(cat /proc/cpuinfo | grep vmx) ]]; then
         sudo modprobe kvm_intel
    elif [[ $(cat /proc/cpuinfo | grep svm) ]]; then
        sudo modprobe kvm_amd
    else
        echo "WARNING: Unable to find an approriate KVM module to load"
    fi
}

initial_setup() {
    libvirt_dir="/etc/libvirt/"

    if [[ ! -e "${libvirt_dir}" ]]; then
        dir="${libvirt_dir}"
        missing_directory
    fi
}

main

exec /usr/bin/env sudo libvirtd --listen --config "${libvirt_dir}/libvirtd.conf"

execution_should_never_reach_here
