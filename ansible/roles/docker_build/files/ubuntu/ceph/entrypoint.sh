#!/bin/bash

set -o errexit

mon_main() {
    mon_initial_setup

    if [[ -n "${INITIAL_CLUSTER}" ]]; then
        mon_bootstrap
    fi

    mon_file_check

    if [[ ! -e "${mon_dir}/keyring" ]]; then
        mon_create_keyring
    fi
}

mon_create_keyring() {
    ceph-authtool --create-keyring "${keyring_montmp}" \
                                            --import-keyring "${keyring_admin}"

    ceph-authtool "${keyring_montmp}" --import-keyring "${keyring_mon}"

    mkdir -p "${mon_dir}"

    ceph-mon --mkfs -i "${MON_NAME}" --monmap "${monmap}" \
                                                   --keyring "${keyring_montmp}"

    rm "${keyring_montmp}"
}

mon_bootstrap() {
    fsid="$(awk '/^fsid/ {print $3; exit}' ${ceph_conf})"

    ceph-authtool --create-keyring "${keyring_mon}" --gen-key -n mon. \
                                                            --cap mon 'allow *'

    ceph-authtool --create-keyring "${keyring_admin}" \
                      --gen-key -n client.admin --set-uid=0 \
                      --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow'

    ceph-authtool "${keyring_mon}" --import-keyring "${keyring_admin}"

    monmaptool --create --add "${MON_NAME}" "${MON_IP}" --fsid "${fsid}" "${monmap}"

    exit 0
}

mon_file_check() {
    for file in "${keyring_admin}" "${keyring_mon}" "${monmap}"; do
             [[ -e "${file}" ]] || missing_file
    done
}

mon_initial_setup() {
    if [[ ! -n "${MON_NAME}" ]]; then
            variable_name="MON_NAME"
            unset_variable
    fi

    if [[ ! -n "${MON_IP}" ]]; then
            variable_name="MON_IP"
            unset_variable
    fi

    keyring_admin="/etc/ceph/${CEPH_CLUSTER_NAME}.client.admin.keyring"
    keyring_mon="/etc/ceph/${CEPH_CLUSTER_NAME}.mon.keyring"
    monmap="/etc/ceph/${CEPH_CLUSTER_NAME}.monmap"
    mon_dir="/var/lib/ceph/mon/${CEPH_CLUSTER_NAME}-${MON_NAME}"
    keyring_montmp="/tmp/${CEPH_CLUSTER_NAME}.mon.keyring"
}

initial_setup() {
    if [[ ! -n "${SERVICE}" ]]; then
        variable_name="SERVICE"
        unset_variable
    fi

    if [[ "${SERVICE}" != "mon" && "${SERVICE}" != "osd" ]]; then
        echo "ERROR: \"SERVICE\" variable must be either \"mon\" or \"osd\""
        exit 51
    fi

    if [[ ! -n "${CEPH_CLUSTER_NAME}" ]]; then
        variable_name="CEPH_CLUSTER_NAME"
        unset_variable
    fi

    ceph_conf="/etc/ceph/${CEPH_CLUSTER_NAME}.conf"

    if [[ ! -e "${ceph_conf}" ]]; then
        file="${ceph_conf}"
        missing_file
    fi
}

osd_initial_setup() {
    keyring_admin="/etc/ceph/${CEPH_CLUSTER_NAME}.client.admin.keyring"

    if [[ ! -e "${keyring_admin}" ]]; then
        file="${keyring_admin}"
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

main() {
    initial_setup

    if [[ "${SERVICE}" == "mon" ]]; then
        mon_main
        exec /usr/bin/ceph-mon -d -i "${MON_NAME}" --public-addr "${MON_IP}:6789"
        exit $?
    fi

    if [[ "${SERVICE}" == "osd" ]]; then
        osd_main
        exec ceph-osd -f -d -i "${OSD_ID}" --osd-journal "${osd_dir}/journal" -k "${osd_dir}/keyring"
        exit $?
    fi
}

osd_main() {
    osd_initial_setup

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

main

execution_should_never_reach_here
