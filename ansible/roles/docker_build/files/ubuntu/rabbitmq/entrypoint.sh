#!/bin/bash

set -o errexit

source /opt/yaodu/errors.sh

main() {
    initial_setup

    if [[ -n "${JOIN_CLUSTER}" ]]; then
        if [[ ! -n "${NODE_TO_JOIN}" ]]; then
            variable="NODE_TO_JOIN"
            missing_variable
        fi

        /usr/sbin/rabbitmq-server &
	pid=$!

	rabbitmq-plugins enable --online rabbitmq_management

	rabbitmqctl stop_app
	rabbitmqctl join_cluster "rabbit@${NODE_TO_JOIN}"
	rabbitmqctl start_app

	rabbitmqctl stop

	wait "${pid}"
	exit $?
    fi
}

initial_setup() {
    _erlang_cookie="/var/lib/rabbitmq/.erlang.cookie"

    if [[ ! -e "${_erlang_cookie}" ]]; then
        file="${_erlang_cookie}"
        missing_file
    fi

    chown -R rabbitmq: /var/lib/rabbitmq/
}

main

exec /usr/sbin/rabbitmq-server
exit $?

execution_should_never_reach_here
