#!/bin/bash

set -o errexit

source /opt/yaodu/errors.sh

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

main

exec /usr/sbin/haproxy -db -f "${haproxy_cfg}"
exit $?

execution_should_never_reach_here
