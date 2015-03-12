#!/bin/bash

set -o errexit

main() {
    initial_setup

    if [[ -n "${INITIAL_CLUSTER}" ]]; then
        fsid="$(awk '/^fsid/ {print $3; exit}' ${ceph_conf})"

        ceph-authtool --create-keyring "${keyring_mon}" \
                --gen-key -n mon. \
                --cap mon 'allow *'

        ceph-authtool --create-keyring "${keyring_admin}" \
                --gen-key -n client.admin --set-uid=0 \
                --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow'

        ceph-authtool "${keyring_mon}" --import-keyring "${keyring_admin}"

        monmaptool --create --add "${MON_NAME}" "${MON_IP}" --fsid "${fsid}" \
                                                                           "${monmap}"

	exit 0
    fi

    file_check

    if [[ ! -e "${mon_dir}/keyring" ]]; then
         ceph-authtool --create-keyring "${keyring_montmp}" \
                                            --import-keyring "${keyring_admin}"

         ceph-authtool "${keyring_montmp}" --import-keyring "${keyring_mon}"

         mkdir -p "${mon_dir}"

         ceph-mon --mkfs -i "${MON_NAME}" --monmap "${monmap}" \
                                                   --keyring "${keyring_montmp}"

         rm "${keyring_montmp}"
    fi
}

file_check() {
    for file in "${keyring_admin}" "${keyring_mon}" "${monmap}"; do
             [[ -e "${file}" ]] || missing_file
    done
}

initial_setup() {
    if [[ ! -n "${CEPH_CLUSTER_NAME}" ]]; then
            variable_name="CEPH_CLUSTER_NAME"
            unset_variable
    fi

    if [[ ! -n "${MON_NAME}" ]]; then
            variable_name="MON_NAME"
            unset_variable
    fi

    if [[ ! -n "${MON_IP}" ]]; then
            variable_name="MON_IP"
            unset_variable
    fi

    ceph_conf="/etc/ceph/${CEPH_CLUSTER_NAME}.conf"
    keyring_admin="/etc/ceph/${CEPH_CLUSTER_NAME}.client.admin.keyring"
    keyring_mon="/etc/ceph/${CEPH_CLUSTER_NAME}.mon.keyring"
    monmap="/etc/ceph/${CEPH_CLUSTER_NAME}.monmap"
    mon_dir="/var/lib/ceph/mon/${CEPH_CLUSTER_NAME}-${MON_NAME}"
    keyring_montmp="/tmp/${CEPH_CLUSTER_NAME}.mon.keyring"

    if [[ ! -e "${ceph_conf}" ]]; then
        file="${ceph_conf}"
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

exec /usr/bin/ceph-mon -d -i "${MON_NAME}" --public-addr "${MON_IP}:6789"
