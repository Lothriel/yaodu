#!/bin/bash

set -o errexit

main() {
    initial_setup
}

initial_setup() {
    keepalived_conf="/etc/keepalived/keepalived.conf"

    if [[ ! -e "${keepalived_conf}" ]]; then
        file="${keepalived_conf}"
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

exec /usr/sbin/keepalived -n
