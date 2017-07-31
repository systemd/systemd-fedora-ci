#!/bin/bash

set -x
set -e
set -o pipefail

declare -A asset_arch_failure
asset_arch_failure[assert-architecture-x86-64.service]=assert-architecture-x86-64.service
asset_arch_failure[assert-architecture-x86.service]=assert-architecture-x86.service
asset_arch_failure[assert-architecture-s390.service]=assert-architecture-s390.service
asset_arch_failure[assert-architecture-aarch64.service]=assert-architecture-aarch64.service
asset_arch_failure[assert-architecture-ppc64.service]=assert-architecture-ppc64.service
asset_arch_failure[assert-architecture-ppc64le.service]=assert-architecture-ppc64le.service

arch=$(uname --hardware-platform)

if [ $(arch) == "x86_64" ]
then
    assert_arch="assert-architecture-x86-64.service"
elif [ $(arch) == "s390" ]
then
    assert_arch="assert-architecture-s390.service"
elif [ $(arch) == "x86" ]
then
    assert_arch="assert-architecture-x86.service"
elif [ $(arch) == "aarch64" ]
then
    assert_arch="assert-architecture-aarch64.service"
elif [ $(arch) == "ppc64" ]
then
    assert_arch="assert-architecture-ppc64.service"
elif [ $(arch) == "ppc64le" ]
then
    assert_arch="assert-architecture-ppc64le.service"
fi

printf "starting service $assert_arch ..."

systemctl start "$assert_arch"

printf "starting service $assert_arch_failure ..."

for i in "${!asset_arch_failure[@]}"
do
    if [ "$assert_arch" != "$i" ]
    then
        set +e
        systemctl start "$i"
        status=$?
        set -e

        [[ $status = 1 ]]
    fi
done
