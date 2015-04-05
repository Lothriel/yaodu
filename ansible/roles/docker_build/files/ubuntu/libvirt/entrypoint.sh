#!/bin/bash

set -o errexit

source /opt/yaodu/common.sh

main() {
    initial_setup

    sudo /opt/yaodu/kvm_bootstrap
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
