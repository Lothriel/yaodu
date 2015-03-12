#!/bin/bash

set -o errexit

main() {
    initial_setup

    if [[ -n "${INITIALIZE_OSD}" ]]; then
    	if [[ ! -n "${HOSTNAME}" ]]; then
                variable_name="HOSTNAME"
            	unset_variable
	fi

	if [[ ! -n "${OSD_DEV}" ]]; then
                variable_name="OSD_DEV"
            	unset_variable
	fi

	parted "${OSD_DEV}" -s -- mklabel gpt
	ceph-disk prepare "${OSD_DEV}"


	osd_id="$(ceph osd create)"
        osd_dir="/var/lib/ceph/osd/${CEPH_CLUSTER_NAME}-${osd_id}"

	mkdir -p "${osd_dir}"

	mount "${OSD_DEV}1" "${osd_dir}"

	ceph-osd -i "${osd_id}" --mkfs --mkkey
	ceph auth add "osd.${osd_id}" osd 'allow *' mon 'allow profile osd' \
					     	        -i "${osd_dir}/keyring"

	ceph osd crush add-bucket "${HOSTNAME}" host
	ceph osd crush move "${HOSTNAME}" root=default
	ceph osd crush add "${osd_id}" 1.0 host="${HOSTNAME}"

	umount "${osd_dir}"

	exit 0
    fi

    if [[ ! -n "${OSD_ID}" ]]; then
            variable_name="OSD_ID"
            unset_variable
    fi

    osd_dir="/var/lib/ceph/osd/${CEPH_CLUSTER_NAME}-${OSD_ID}"
}

initial_setup() {
    if [[ ! -n "${CEPH_CLUSTER_NAME}" ]]; then
            variable_name="CEPH_CLUSTER_NAME"
            unset_variable
    fi

    ceph_conf="/etc/ceph/${CEPH_CLUSTER_NAME}.conf"
    keyring_admin="/etc/ceph/${CEPH_CLUSTER_NAME}.client.admin.keyring"

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
    exit 31
}

missing_file() {
    echo "ERROR: \"${file}\" does not exist"
    exit 32
}

main

exec ceph-osd -f -d -i "${OSD_ID}" --osd-journal "${osd_dir}/journal" -k "${osd_dir}/keyring"
