#!/bin/bash

set -o errexit

source /opt/yaodu/common.sh

main() {
    initial_setup

    if [[ ! -d /var/lib/mysql/mysql ]]; then
        mysql_install_db --no-defaults --defaults-file=/etc/mysql/my.cnf
    fi

    if [[ -n "${BOOTSTRAP}" ]]; then
	if [[ -e /var/lib/mysql/grastate.dat ]]; then
	    echo "WARNING: Cluster already exists"
	    return
	fi

	if [[ ! -n "${DATABASE_ROOT_PASSWORD}" ]]; then
            variable_name="DATABASE_ROOT_PASSWORD"
	    unset_variable
	fi

	/usr/sbin/mysqld --wsrep-new-cluster &
	pid=$!

	sleep 15
        bootstrap_database

	mysql -u root --password="${DATABASE_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '${DATABASE_ROOT_PASSWORD}' WITH GRANT OPTION;"
	mysql -u root --password="${DATABASE_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${DATABASE_ROOT_PASSWORD}' WITH GRANT OPTION;"

	mysql -u root --password="${DATABASE_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON *.* TO 'haproxy'@'localhost';"
	mysql -u root --password="${DATABASE_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON *.* TO 'haproxy'@'%';"

	wait "${pid}"
	exit $?
    fi
}

bootstrap_database() {
        expect -c '
        set timeout 10
        spawn mysql_secure_installation

        expect "Enter current password for root (enter for none):"
        send "\r"

        expect "Set root password?"
        send "y\r"

        expect "New password:"
        send "'"${DATABASE_ROOT_PASSWORD}"'\r"

        expect "Re-enter new password:"
        send "'"${DATABASE_ROOT_PASSWORD}"'\r"

        expect "Remove anonymous users?"
        send "y\r"

        expect "Disallow root login remotely?"
        send "y\r"

        expect "Remove test database and access to it?"
        send "y\r"

        expect "Reload privilege tables now?"
        send "y\r"

        expect eof'
}



initial_setup() {
    galera_cnf="/etc/mysql/conf.d/galera.cnf"

    if [[ ! -e "${galera_cnf}" ]]; then
        file="${galera_cnf}"
        missing_file
    fi
}

main

exec /usr/sbin/mysqld
exit $?

execution_should_never_reach_here
