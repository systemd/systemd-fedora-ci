#!/bin/bash

set -x
set -e
set -o pipefail

Path="/tmp/nspawn-test"

if [ -f /etc/fedora-release ]
then
    dnf -y --nogpg --releasever=rawhide --installroot="$Path" install systemd dnf fedora-release iproute nc
else
    dnf -y --nogpg --releasever=8 --installroot="$Path" install systemd passwd dnf redhat-release vim-minimal iproute nc
fi

/usr/bin/systemd-nspawn --register=no --drop-capability=CAP_NET_RAW --bind=/tmp -D "$Path" /bin/bash << EOF

/usr/sbin/capsh --print | grep cap_net_raw   > /tmp/cap_net_raw
/usr/sbin/capsh --print | grep cap_sys_admin > /tmp/cap_sys_admin
EOF

[[ ! -s "/tmp/cap_net_raw" ]]

[[ -s "/tmp/cap_sys_admin" ]]

/usr/bin/systemd-nspawn --register=no --private-network --bind=/tmp -D "$Path" /bin/bash << EOF

/usr/sbin/ip -o link show | awk -F': ' '{print $2}' | wc -l > /tmp/private-networking
/usr/sbin/ip -o link show > /tmp/private-networking-interface
EOF

read PrivateNetworking <  /tmp/private-networking
[[ "$PrivateNetworking" == "1" ]]

read PrivateNetworkingInterface <  /tmp/private-networking-interface
[[ "$(echo $PrivateNetworkingInterface | awk -F': ' '{print $2}')" == "lo" ]]

/usr/sbin/ip link add veth99 type veth peer name veth-peer99

/usr/bin/systemd-nspawn --register=no --network-macvlan=veth99 --bind=/tmp -D "$Path" /bin/bash << EOF

/usr/sbin/ip -o link show | awk -F': ' '{print $2}' | wc -l > /tmp/macvlan-networking
/usr/sbin/ip -d link show mv-veth99 | grep macvlan  > /tmp/macvlan-networking-interface
EOF

read MacvlanNetworking <  /tmp/macvlan-networking
[[ "$MacvlanNetworking" == "2" ]]

read MacvlanNetworkingInterface <  /tmp/macvlan-networking-interface
[[ "$(echo $MacvlanNetworkingInterface | /bin/awk '{print $1}')" == "macvlan" ]]

# Look for ipvlan module is supported ?

set +e
modprobe ipvlan
ret=$?
set -e

if [ "$ret" == "0" ]
then
    /usr/bin/systemd-nspawn --register=no --network-ipvlan=veth99 --bind=/tmp -D "$Path" /bin/bash << EOF

    /bin/ls -A /sys/class/net | wc -l > /tmp/ipvlan-networking
    /usr/sbin/ip -d link show iv-veth99 | grep ipvlan > /tmp/ipvlan-networking-interface

EOF
    read IpVlanNetworking <  /tmp/ipvlan-networking
    [[ "$IpVlanNetworking" == "2" ]]

    read IpVlanNetworkingInterface <  /tmp/ipvlan-networking-interface
    [[ "$(echo $IpVlanNetworkingInterface | /bin/awk '{print $1}')" == "ipvlan" ]]
fi

/usr/bin/systemd-nspawn --register=no --network-veth --bind=/tmp -D "$Path" /bin/bash  << EOF

/usr/sbin/ip -o link show | awk -F': ' '{print $2}' | wc -l > /tmp/veth-networking
/usr/sbin/ip -d link show host0 | grep veth > /tmp/veth-networking-interface
EOF

read VethNetworking <  /tmp/veth-networking
[[ "$VethNetworking" == "2" ]]

read VethNetworkingInterface <  /tmp/veth-networking-interface
[[ "$(echo $VethNetworkingInterface | /bin/awk '{print $1}')" == "veth" ]]

touch /tmp/testok
