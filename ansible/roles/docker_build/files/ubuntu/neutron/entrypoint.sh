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

        if [[ ! -e "${openvswitch_dir}/conf.db" ]]; then
            ovsdb-tool create
        fi

        exec /usr/bin/env ovsdb-server /etc/openvswitch/conf.db -vfile:dbg --remote=ptcp:6633 --log-file=/var/log/openvswitch/ovsdb-server.log
        execution_should_never_reach_here
    fi

    if [[ "${SERVICE}" == "switch" ]]; then
        if [[ ! -n "${REMOTE_IP}" ]]; then
            variable_name="REMOTE_IP"
            unset_variable
        fi

        sudo modprobe openvswitch

        exec /usr/bin/env sudo ovs-vswitchd "tcp:${REMOTE_IP}:6633" -vfile:dbg --mlockall --log-file=/var/log/openvswitch/ovs-vswitchd.log
        execution_should_never_reach_here
    fi

    neutron_dir="/etc/neutron/"

    if [[ ! -e "${neutron_dir}" ]]; then
        dir="${neutron_dir}"
        missing_directory
    fi
}

initial_setup() {
    services=("server" "l3-agent" "dhcp-agent" "openvswitch-agent" "db" "switch")

    if [[ ! -n "${SERVICE}" ]]; then
        variable_name="SERVICE"
        unset_variable
    fi

    if [[ ! "${services[@]}" =~ (^| )"${SERVICE}"($| ) ]]; then
        invalid_service
    fi
}

main

exec /usr/bin/env "neutron-${SERVICE}" --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini --log-file="/var/log/neutron/neutron-${SERVICE}.log"

execution_should_never_reach_here
