#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1+
# ~~~
#   runtest.sh of activate
#   Description: Test for activate
# ~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="systemd"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE

        rlRun "cp systemd-socket-activate.service /var/run/systemd/system"
        rlRun "cp systemd-socket-activate-tests.py /usr/bin/systemd-socket-activate-tests.py"
        rlRun "systemctl daemon-reload"
    rlPhaseEnd

    rlPhaseStartTest
        rlLog "Socket activate Test"
        rlRun "/usr/bin/python3 /usr/bin/systemd-socket-activate-tests.py"
     rlPhaseEnd

     rlPhaseStartCleanup
        rlRun "rm /var/run/systemd/system/systemd-socket-activate.service /usr/bin/systemd-socket-activate-tests.py"
       rlRun "systemctl daemon-reload"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
