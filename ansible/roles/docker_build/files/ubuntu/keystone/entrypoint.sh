#!/bin/bash

set -o errexit

source /opt/yaodu/common.sh

main() {
    if [[ -n "${BOOTSTRAP}" ]]; then
        keystone-manage db_sync
        exit
    fi

    initial_setup
}

initial_setup() {
    keystone_dir="/etc/keystone/"

    if [[ ! -e "${keystone_dir}" ]]; then
        dir="${keystone_dir}"
        missing_directory
    fi
}

main

exec /usr/bin/env keystone-all
exit $?

execution_should_never_reach_here
