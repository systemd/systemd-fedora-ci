#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1+
# ~~~
#   runtest.sh of https://github.com/systemd/systemd/issues/2467
#   Description: don't start services every few ms if condition fails.
# ~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="systemd"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE
        rlRun "cp test.service test.socket testsuite.service /var/run/systemd/system"
        rlRun "systemctl daemon-reload"
    rlPhaseEnd

    rlPhaseStartTest
	rlLog "Don't start services every few ms if condition fails."

	rlLog "starting testsuite.service"
        rlRun "systemctl start testsuite.service" 1
        rlAssertNotExists "/var/run/testok"
    rlPhaseEnd

    rlPhaseStartCleanup
       rlRun "rm /var/run/systemd/system/test.service /var/run/systemd/system/test.socket /var/run/systemd/system/testsuite.service"
       rlRun "systemctl daemon-reload"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
rlJournalPrintText
