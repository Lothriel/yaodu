#!/bin/bash

set -o errexit

main() {
    initial_setup

    if [[ ! -e "${whoami}" ]]; then
	osd_id="$(ceph osd create)"
	osd_dir="${osd_basedir}/${CEPH_CLUSTER_NAME}-${osd_id}"
	ln -s "osd" "${osd_dir}"

	ceph-osd -i "${osd_id}" --mkfs --mkkey
	ceph auth add "osd.${osd_id}" osd 'allow *' mon 'allow profile osd' \
							-i "${osd_dir}/keyring"

	ceph osd crush add-bucket "${HOSTNAME}" host
	ceph osd crush move "${HOSTNAME}" root=default
	ceph osd crush add "${osd_id}" 1.0 host="${HOSTNAME}"
    else
    	osd_id="$(cat ${whoami})"
	osd_dir="${osd_basedir}/${CEPH_CLUSTER_NAME}-${osd_id}"
	ln -s "osd" "${osd_dir}"
    fi
}

initial_setup() {
    if [[ ! -n "${CEPH_CLUSTER_NAME}" ]]; then
            variable_name="CEPH_CLUSTER_NAME"
            unset_variable
    fi

    if [[ ! -n "${HOSTNAME}" ]]; then
            variable_name="HOSTNAME"
            unset_variable
    fi

    ceph_conf="/etc/ceph/${CEPH_CLUSTER_NAME}.conf"
    keyring_admin="/etc/ceph/${CEPH_CLUSTER_NAME}.client.admin.keyring"
    osd_basedir="/var/lib/ceph/osd"
    whoami="${osd_basedir}/osd/whoami"

    if [[ ! -e "${ceph_conf}" ]]; then
        file="${ceph_conf}"
        missing_file
    fi

    if [[ ! -e "${keyring_admin}" ]]; then
	file="${keyring_admin}"
	missing_file
    fi
}

unset_variable() {
    echo "ERROR: \"${variable_name}\" is a required variable"
    exit 1
}

missing_file() {
    echo "ERROR: \"${file}\" does not exist"
    exit 2
}

main

exec ceph-osd -f -d -i "${osd_id}" --osd-journal "${osd_dir}/journal" -k "${osd_dir}/keyring"
