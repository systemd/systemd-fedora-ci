#!/bin/bash

virtualization=$(systemd-detect-virt)

set -x
set -e
set -o pipefail

if [ $virtualization == none ]
then
    condition_virtualization=condition-virtualization-none.service
elif [ $virtualization == kvm ]
then
    condition_virtualization=condition-virtualization-kvm.service
elif [ $virtualization == qemu ]
then
    condition_virtualization=condition-virtualization-qemu.service
elif [ $virtualization == vmware ]
then
    condition_virtualization=condition-virtualization-vmware.service
elif [ $virtualization == lxc ]
then
    condition_virtualization=condition-virtualization-lxc.service
elif [ $virtualization == lxc-libvirt ]
then
    condition_virtualization=condition-virtualization-lxc-libvirt.service
elif [ $virtualization == systemd-nspawn ]
then
    condition_virtualization=condition-virtualization-systemd-nspawn.service
elif [ $virtualization == docker ]
then
    condition_virtualization=condition-virtualization-docker.service
elif [ $virtualization == rkt ]
then
    condition_virtualization=condition-virtualization-rkt.service
else
    exit 0
fi

systemctl start $condition_virtualization
status="$(systemctl status $condition_virtualization | grep status=0/SUCCES)"
[[ $status = *"status=0/SUCCES"* ]]
