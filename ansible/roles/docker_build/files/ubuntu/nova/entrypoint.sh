#!/bin/bash

set -o errexit

source /opt/yaodu/errors.sh

main() {
    initial_setup
}

initial_setup() {
    nova_dir="/etc/nova/"

    if [[ ! -e "${nova_dir}" ]]; then
        dir="${nova_dir}"
        missing_directory
    fi
}

main

exec /usr/bin/keystone-all
exit $?

execution_should_never_reach_here
