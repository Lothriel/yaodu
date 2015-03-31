#!/bin/bash

set -o errexit

source /opt/yaodu/common.sh

main() {
    initial_setup
}

initial_setup() {
    glance_dir="/etc/glance/"
    services=("api" "registry")

    if [[ ! -n "${SERVICE}" ]]; then
        variable_name="SERVICE"
        unset_variable
    fi

    if [[ ! "${services[@]}" =~ (^| )"${SERVICE}"($| ) ]]; then
        invalid_service
    fi

    if [[ ! -e "${glance_dir}" ]]; then
        dir="${glance_dir}"
        missing_directory
    fi
}

main

exec /usr/bin/env "glance-${SERVICE}"

execution_should_never_reach_here
