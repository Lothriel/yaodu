#!/bin/bash

set -o errexit

source /opt/yaodu/errors.sh

main() {
    initial_setup

    if [[ "${SERVICE}" == "db" ]]; then
        openvswitch_dir="/etc/openvswitch/"

        if [[ ! -e "${openvswitch_dir}" ]]; then
            dir="${openvswitch_dir}"
            missing_directory
        fi

        exec /usr/bin/env ovsdb-server /etc/openvswitch/conf.db -vfile:dbg --remote=ptcp:6168 --log-file=/var/log/openvswitch/ovsdb-server.log
    fi

    if [[ "${SERVICE}" == "switch" ]]; then
        if [[ ! -n "${REMOTE_IP}" ]]; then
            variable_name="REMOTE_IP"
            unset_variable
        fi

        exec /usr/bin/env ovs-vswitchd "tcp:${REMOTE_IP}:6168" -vfile:dbg --mlockall --log-file=/var/log/openvswitch/ovs-vswitchd.log
    fi
}

initial_setup() {
    services=("db" "switch")

    if [[ ! -n "${SERVICE}" ]]; then
        variable_name="SERVICE"
        unset_variable
    fi

    if [[ ! "${services[@]}" =~ (^| )"${SERVICE}"($| ) ]]; then
        invalid_service
    fi
}

main

execution_should_never_reach_here
