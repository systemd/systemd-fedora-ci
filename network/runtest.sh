#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1+
# ~~~
#   runtest.sh of systemd networkd
#   Description: Test for systemd.network — Network device configuration
# ~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="systemd"
network_unit_file_path='/var/run/systemd/network'
networkd_ci_path='/var/run/networkd-ci'

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE
        rlRun "setenforce 0" 0,1
        rlRun "systemctl stop firewalld" 0,5
        rlRun "mkdir -p $network_unit_file_path $networkd_ci_path"
        rlRun "cp conf/*.netdev conf/*.network $networkd_ci_path"
        rlRun "cp systemd-networkd-tests.py /usr/bin"
    rlPhaseEnd

    rlPhaseStartTest
        rlRun "/usr/bin/python3 /usr/bin/systemd-networkd-tests.py"
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "setenforce 1" 0,1
        rlRun "systemctl restart systemd-networkd"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
