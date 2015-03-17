#!/bin/bash

set -o errexit

source /opt/yaodu/errors.sh

main() {
    initial_setup

    if [[ -n "${INITIAL}" ]]; then
        if [[ ! -n "${NODE_TO_JOIN}" ]]; then
            variable="NODE_TO_JOIN"
            missing_variable
        fi

        /usr/sbin/rabbitmq-server &
	pid=$!

        sleep 15

	rabbitmq-plugins enable --online rabbitmq_management

        if [[ "${NODE_TO_JOIN}" != "$(hostname)" ]]; then
	    rabbitmqctl stop_app
            rabbitmqctl join_cluster "rabbit@${NODE_TO_JOIN}"
            rabbitmqctl start_app
        fi

	rabbitmqctl stop

	wait "${pid}"
	exit $?
    fi

    if [[ ! -e "${_erlang_cookie}" ]]; then
        file="${_erlang_cookie}"
        missing_file
    fi
}

initial_setup() {
    _erlang_cookie="/var/lib/rabbitmq/.erlang.cookie"

    chown -R rabbitmq: /var/lib/rabbitmq/
}

main

/usr/sbin/rabbitmq-server
exit $?

execution_should_never_reach_here
