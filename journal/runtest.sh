#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1+
# ~~~
#   runtest.sh of journald
#   Description: Test for journal
# ~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="systemd"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE
        rlRun "cp forever-print-hola.service testsuite.service /var/run/systemd/system"
        rlRun "cp test-journal.sh /usr/bin"
        rlRun "systemctl daemon-reload"
    rlPhaseEnd

    rlPhaseStartTest
	rlLog "starting forever-print-hola.service"
     	rlRun "systemctl start forever-print-hola.service"

        rlLog "starting testsuite.service"
     	rlRun "systemctl start testsuite.service"
        rlAssertExists "/tmp/testok"
    rlPhaseEnd

    rlPhaseStartCleanup
       rlRun "rm /tmp/testok /var/run/systemd/system/forever-print-hola.service /var/run/systemd/system/testsuite.service /usr/bin/test-journal.sh"
       rlRun "systemctl daemon-reload"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
