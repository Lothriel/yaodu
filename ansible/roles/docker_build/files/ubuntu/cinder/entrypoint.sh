#!/bin/bash

set -o errexit

source /opt/yaodu/common.sh

main() {
    initial_setup
}

initial_setup() {
    cinder_dir="/etc/cinder/"
    services=("api" "scheduler" "volume" "backup")

    if [[ ! -n "${SERVICE}" ]]; then
        variable_name="SERVICE"
        unset_variable
    fi

    if [[ ! "${services[@]}" =~ (^| )"${SERVICE}"($| ) ]]; then
        invalid_service
    fi

    if [[ ! -e "${cinder_dir}" ]]; then
        dir="${cinder_dir}"
        missing_directory
    fi
}

main

exec /usr/bin/env "cinder-${SERVICE}" --log-file="/var/log/cinder/cinder-${SERVICE}.log"

execution_should_never_reach_here
