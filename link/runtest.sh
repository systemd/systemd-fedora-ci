#!/bin/bash
#  SPDX-License-Identifier: LGPL-2.1+
# ~~~
#   runtest.sh of systemd link
#   Description: Test for systemd.link — Network device configuration
#
#   Author: Susant Sahani <susant@redhat.com>
#   Copyright (c) 2018 Red Hat, Inc.
# ~~~
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="systemd"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE
        rlLog "Link Network device configuration"
    rlPhaseEnd

    rlPhaseStartTest
        rlLog "Link test: Speed, MTU, tcp-segmentation-offload generic-segmentation-offload generic-receive-offload"

        rlRun "cp 00-test.link /etc/systemd/network/00-test.link"

        rlRun "ip link add name test99 type veth peer name test99-guest"
        rlRun "ip link set dev test99 addr 00:01:02:aa:bb:cc"
        rlRun "ip link set dev test99 up"

        rlRun "udevadm test-builtin net_setup_link /sys/class/net/test99"

        rlRun "[[ \"$(cat /sys/class/net/test99/speed)\" == \"10000\" ]]"
        rlRun "[[ \"$(cat /sys/class/net/test99/mtu)\" == \"1280\" ]]"

        rlRun "[[ \"$(ethtool -k test99 | grep tcp-segmentation-offload)\" == \"tcp-segmentation-offload: on\" ]]"
        rlRun "[[ \"$(ethtool -k test99 | grep generic-segmentation-offload)\" == \"generic-segmentation-offload: on\" ]]"
        rlRun "[[ \"$(ethtool -k test99 | grep generic-receive-offload)\" == \"generic-receive-offload: on\" ]]"

        rlRun "ip link del test99"
        rlRun "rm /etc/systemd/network/00-test.link"
    rlPhaseEnd

    rlPhaseStartTest
        rlLog "systemd link test: MACAddress=, Alias="

        rlRun "cp 00-test1.link /etc/systemd/network/00-test1.link"

        rlRun "ip link add name test99 type dummy"
        rlRun "ip link set dev test99 addr 00:01:02:aa:bb:cc"
        rlRun "udevadm test-builtin net_setup_link /sys/class/net/test99"

        rlRun "udevadm test-builtin net_setup_link /sys/class/net/test99"

        rlRun "[[ \"$(cat /sys/class/net/test99/ifalias)\" == \"testalias99\" ]]"
        rlRun "[[ \"$(cat /sys/class/net/test99/address)\" == \"00:01:02:aa:bb:cd\" ]]"

        rlRun "ip link del test99"
        rlRun "rm /etc/systemd/network/00-test1.link"
    rlPhaseEnd

    rlPhaseStartCleanup
       rlRun "systemctl daemon-reload"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
