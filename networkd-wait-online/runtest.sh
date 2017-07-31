#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1+
# ~~~
#   runtest.sh of systemd networkd wait online
#   Description: Test for systemd-networkd-wait-online — Network device configuration
# ~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="systemd"
NETWORK_UNIT_FILE_PATH='/var/run/systemd/network'
NETWORKD_CI_PATH='/var/run/networkd-ci'

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE
        rlRun "mkdir -p $NETWORK_UNIT_FILE_PATH"
        rlRun "mkdir -p $NETWORKD_CI_PATH"
        rlRun "cp *.netdev *.network  $NETWORKD_CI_PATH"
        rlLog "networkd-wait-online tests"
    rlPhaseEnd

    rlPhaseStartTest
	rlRun "/usr/bin/python3 systemd-networkd-waitonline-tests.py"
    rlPhaseEnd

    rlPhaseStartCleanup
       rlRun "rm -rf $NETWORKD_CI_PATH"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
