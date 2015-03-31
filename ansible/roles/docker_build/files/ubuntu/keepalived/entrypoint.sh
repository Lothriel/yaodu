#!/bin/bash

set -o errexit

source /opt/yaodu/common.sh

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

main

exec /usr/sbin/keepalived -n
exit $?

execution_should_never_reach_here
