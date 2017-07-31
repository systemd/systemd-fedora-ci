#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1+
# ~~~
#   runtest.sh of systemd-nspawn
#   Description: Test for systemd-nspawn
#
#   Author: Susant Sahani <susant@redhat.com>
#   Copyright (c) 2018 Red Hat, Inc.
# ~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="systemd"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE
        rlRun "cp testsuite.service /etc/systemd/system/testsuite.service"
        rlRun "cp test-nspawn.sh /usr/bin/"
        rlRun "systemctl daemon-reload"
    rlPhaseEnd

    rlPhaseStartTest
	rlLog "systemd-nspawn tests"

	rlLog "starting testsuite.service"
     	rlRun "systemctl start testsuite.service"
        rlAssertExists "/tmp/testok"
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "/usr/sbin/ip link del veth99"
        rlRun "rm /tmp/testok /usr/bin/test-nspawn.sh /tmp/cap_net_raw /tmp/cap_sys_admin /tmp/private-networking"
        rlRun "rm -rf /tmp/nspawn-test"
        rlRun "systemctl daemon-reload"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
