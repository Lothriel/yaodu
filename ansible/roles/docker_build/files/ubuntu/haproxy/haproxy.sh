#!/bin/bash

set -o errexit

main() {
    initial_setup
}

initial_setup() {
    haproxy_cfg="/etc/haproxy/haproxy.cfg"

    if [[ ! -e "${haproxy_cfg}" ]]; then
        file="${haproxy_cfg}"
        missing_file
    fi
}

unset_variable() {
    echo "ERROR: \"${variable_name}\" is a required variable"
    exit 31
}

missing_file() {
    echo "ERROR: \"${file}\" does not exist"
    exit 32
}

main

exec /usr/sbin/haproxy -db -f "${haproxy_cfg}"
