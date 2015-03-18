#!/bin/bash

set -o errexit

source /opt/yaodu/errors.sh

main() {
    initial_setup
}

initial_setup() {
    glance_dir="/etc/glance/"

    if [[ ! -e "${glance_dir}" ]]; then
        dir="${glance_dir}"
        missing_directory
    fi
}

main

exec /usr/bin/keystone-all
exit $?

execution_should_never_reach_here
