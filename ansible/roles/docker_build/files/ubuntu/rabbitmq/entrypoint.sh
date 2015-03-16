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
    echo "ERROR: Variable \"${variable_name}\" is not set"
    exit 31
}

missing_file() {
    echo "ERROR: File \"${file}\" does not exist"
    exit 32
}

missing_directory() {
    echo "ERROR: Directory \"${dir}\" does not exist"
    exit 33
}

execution_should_never_reach_here() {
    cat << EOF
|-----------------------------------------------------------------------------|
| ERROR     ERROR     ERROR     ERROR     ERROR     ERROR     ERROR     ERROR |
|-----------------------------------------------------------------------------|
| Congratulations! You have reached a point in execution you should not have. |
| You either broke something, or something broke. I blame you. Either way,    |
| please report this with any relevant configs and options.                   |
|-----------------------------------------------------------------------------|
EOF
    exit 42
}

main

exec /usr/sbin/rabbitmq-server
exit $?

execution_should_never_reach_here
