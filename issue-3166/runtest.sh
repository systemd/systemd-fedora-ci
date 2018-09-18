#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1+
# ~~~
#   runtest.sh of https://github.com/systemd/systemd/issues/3166
#   Description: Service doesn't enter the "failed" state
# ~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="systemd"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE

        # setup the testsuite service
        rlRun "cp testsuite.service fail-on-restart.service /var/run/systemd/system"
        rlRun "cp test-fail-on-restart.sh /usr/bin/test-fail-on-restart.sh"
        rlRun "systemctl daemon-reload"
    rlPhaseEnd

    rlPhaseStartTest
	rlLog "Service doesn't enter the failed state"

	rlLog "starting testsuite.service"
     	rlRun "systemctl start testsuite.service" 1
        rlAssertNotExists "/var/run/testok"
    rlPhaseEnd

    rlPhaseStartCleanup
       rlRun "rm /var/run/systemd/system/testsuite.service /usr/bin/test-fail-on-restart.sh /var/run/systemd/system/fail-on-restart.service"
       rlRun "systemctl daemon-reload"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
