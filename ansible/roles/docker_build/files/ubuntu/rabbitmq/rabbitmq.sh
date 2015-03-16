#!/bin/bash

set -o errexit

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

unset_variable() {
    echo "ERROR: \"${variable_name}\" is a required variable"
    exit 31
}

missing_file() {
    echo "ERROR: \"${file}\" does not exist"
    exit 32
}

main

exec /usr/sbin/rabbitmq-server
