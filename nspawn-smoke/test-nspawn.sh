#!/bin/bash
set -x
set -e
set -u
set -o pipefail

export SYSTEMD_LOG_LEVEL=debug

version="$(systemctl --version | grep systemd |  awk '{print $2}')"

_root=/tmp/nspawn-container

function check_bind_tmp_path {
    # https://github.com/systemd/systemd/issues/4789

    local _root="/tmp/nspawn-container/bind-tmp-path"

    /usr/bin/create-busybox-container "$_root"
    >/tmp/bind

    systemd-nspawn --register=no -D "$_root" --bind=/tmp/bind /bin/sh -c 'test -e /tmp/bind'

    rm -rf "$_root"
}

function init_virtual_interfaces {
    ip link add bridge99 type bridge
    ip link add veth99 type veth  peer name veth99-peer
    ip link add dummy99 type dummy
}

function cleanup_virtual_interfaces {
    ip link del bridge99
    ip link del veth99
}

function check_nspawn_networking {

    # init virtual interfaces
    init_virtual_interfaces

    # create minimal filesystem
    /usr/bin/create-busybox-container "$_root"

    systemd-nspawn --register=no -D "$_root"  -b
    systemd-nspawn --register=no -D "$_root"  --private-network -b
    systemd-nspawn --register=no -D "$_root"  --network-interface=dummy99 -b
    systemd-nspawn --register=no -D "$_root"  --network-veth -b
    systemd-nspawn --register=no -D "$_root"  --network-bridge=bridge99 -b
    systemd-nspawn --register=no -D "$_root"  --private-network -b
    systemd-nspawn --register=no -D "$_root"  --network-macvlan=veth99 -b

    # verify whether kernel supports ipvlan module
    set +e

    /usr/sbin/modprobe ipvlan
    ret=$?

    set -e

    if [ "$ret" -eq "0" ]
    then
        systemd-nspawn --register=no -D "$_root"  --network-ipvlan=veth99 -b
    fi

    if [ "$version" -gt "219" ]
    then
        systemd-nspawn --register=no -D "$_root"  --network-veth-extra=dummy99 -b
        systemd-nspawn --register=no -D "$_root"  --network-veth-extra==veth99:veth-container -b
        systemd-nspawn --register=no -D "$_root"  --network-zone=zone -b
    fi

    # cleanup
    cleanup_virtual_interfaces

    rm -rf "$_root"
}

check_bind_tmp_path
check_nspawn_networking

touch /tmp/testok
