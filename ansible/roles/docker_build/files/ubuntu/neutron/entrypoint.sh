#!/bin/bash

set -o errexit

source /opt/yaodu/errors.sh

main() {
    initial_setup
}

initial_setup() {
    neutron_dir="/etc/neutron/"
    services=("server" "l3")

    if [[ ! -n "${SERVICE}" ]]; then
        variable_name="SERVICE"
        unset_variable
    fi

    if [[ ! "${services[@]}" =~ (^| )"${SERVICE}"($| ) ]]; then
        invalid_service
    fi

    if [[ ! -e "${neutron_dir}" ]]; then
        dir="${neutron_dir}"
        missing_directory
    fi
}

main

exec /usr/bin/env "glance-${SERVICE}"

execution_should_never_reach_here
