#!/bin/bash

set -o errexit

source /opt/yaodu/errors.sh

main() {
    initial_setup
}

initial_setup() {
    nova_dir="/etc/nova/"
    services=("api" "scheduler" "console" "consoleauth" "novncproxy" "spicehtml5proxy" "compute")

    if [[ ! -n "${SERVICE}" ]]; then
        variable_name="SERVICE"
        unset_variable
    fi

    if [[ ! "${services[@]}" =~ (^| )"${SERVICE}"($| ) ]]; then
        invalid_service
    fi

    if [[ ! -e "${nova_dir}" ]]; then
        dir="${nova_dir}"
        missing_directory
    fi
}

main

exec /usr/bin/env "nova-${SERVICE}" --log-file="/var/log/nova/nova-${SERVICE}.log"

execution_should_never_reach_here
