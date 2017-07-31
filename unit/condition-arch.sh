#!/bin/bash

set -x
set -e
set -o pipefail

arch=$(uname --hardware-platform)

if [ $(arch) == "x86_64" ]
then
    condition_architecture="condition-architecture-x86-64.service"
elif [ $(arch) == "s390" ]
then
    condition_architecture="condition-architecture-s390.service"
elif [ $(arch) == "x86" ]
then
    condition_architecture="condition-architecture-x86.service"
elif [ $(arch) == "aarch64" ]
then
    condition_architecture="condition-architecture-aarch64.service"
elif [ $(arch) == "ppc64" ]
then
    condition_architecture="condition-architecture-ppc64.service"
elif [ $(arch) == "ppc64le" ]
then
    condition_architecture="condition-architecture-ppc64le.service"
fi

systemctl start $condition_architecture
status="$(systemctl status $condition_architecture | grep status=0/SUCCES)"
[[ $status = *"status=0/SUCCES"* ]]
