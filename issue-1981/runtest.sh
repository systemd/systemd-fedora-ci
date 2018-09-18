#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1+
# ~~~
#   runtest.sh of https://github.com/systemd/systemd/issues/1981
#   Description: Test for timer segfault
# ~~~
# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="systemd"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE

        rlRun "cp testsuite.service /etc/systemd/system/testsuite.service"
        rlRun "cp test-segfault.sh /usr/bin/"
        rlRun "systemctl daemon-reload"
    rlPhaseEnd

    rlPhaseStartTest
        rlLog "Timer segfault test"
        rlLog "starting testsuite.service"
        rlRun "systemctl start testsuite.service"
        rlAssertExists "/tmp/testok"
    rlPhaseEnd

    rlPhaseStartCleanup
       rlRun "rm /tmp/testok /usr/bin/test-segfault.sh /etc/systemd/system/my.timer"
       rlRun "rm -rf /etc/systemd/system/my.timer.d"
       rlRun "systemctl daemon-reload"
    rlPhaseEnd

rlJournalPrintText
rlJournalEnd

rlGetTestState
