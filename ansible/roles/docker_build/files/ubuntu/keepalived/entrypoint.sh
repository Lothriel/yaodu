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

exec /usr/sbin/keepalived -n
exit $?

execution_should_never_reach_here
