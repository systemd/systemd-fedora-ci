#!/bin/bash

virtualization=$(systemd-detect-virt)
echo "virtualization=$virtualization ..."

set -x
set -e
set -o pipefail

declare -A asset_virt_failure
asset_virt_failure[assert-virtualization-docker.service]=assert-virtualization-docker.service
asset_virt_failure[assert-virtualization-none.service]=assert-virtualization-none.service
asset_virt_failure[assert-virtualization-kvm.service]=assert-virtualization-kvm.service
asset_virt_failure[assert-virtualization-lxc.service]=assert-virtualization-lxc.service
asset_virt_failure[assert-virtualization-lxc-libvirt.service]=assert-virtualization-lxc-libvirt.service
asset_virt_failure[assert-virtualization-qemu.service]=assert-virtualization-qemu.service
asset_virt_failure[assert-virtualization-rkt.service]=assert-virtualization-rkt.service
asset_virt_failure[assert-virtualization-vmware.service]=assert-virtualization-vmware.service
asset_virt_failure[assert-virtualization-systemd-nspawn.service]=assert-virtualization-systemd-nspawn.service


if [ $virtualization == "none" ]
then
    assert_virtualization=assert-virtualization-none.service
elif [ $virtualization == "kvm" ]
then
    assert_virtualization=assert-virtualization-kvm.service
elif [ $virtualization == "qemu" ]
then
    assert_virtualization=assert-virtualization-qemu.service
elif [ $virtualization == "vmware" ]
then
    assert_virtualization=assert-virtualization-vmware.service
elif [ $virtualization == "lxc" ]
then
    assert_virtualization=assert-virtualization-lxc.service
elif [ $virtualization == "lxc-libvirt" ]
then
    assert_virtualization=assert-virtualization-lxc-libvirt.service
elif [ $virtualization == "systemd-nspawn" ]
then
    assert_virtualization=assert-virtualization-systemd-nspawn.service
elif [ $virtualization == "docker" ]
then
    assert_virtualization=assert-virtualization-docker.service
elif [ $virtualization == "rkt" ]
then
    assert_virtualization=assert-virtualization-rkt.service
fi

systemctl start "$assert_virtualization"

status="$(systemctl status $assert_virtualization | grep status=0/SUCCES)"
[[ $status = *"status=0/SUCCES"* ]]

printf "starting service $asset_virt_failure ..."

for i in "${!asset_virt_failure[@]}"
do
    if [ "$asset_virt_failure" != "$i" ]
    then
        systemctl start "$i"
    fi
done
