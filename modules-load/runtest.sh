#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1+
# ~~~
#   runtest.sh of systemd-modules-load
#   Description: Test for systemd-modules-load
# ~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="systemd"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE

        rlRun "cp ipip.conf /etc/modules-load.d/ipip.conf"
        rlRun "cp systemd-modules-load-test.py /usr/bin/"
    rlPhaseEnd

    rlPhaseStartTest
        rlLog "systemd-modules-load related test"
        rlRun "/usr/bin/python3 /usr/bin/systemd-modules-load-test.py"
    rlPhaseEnd

    rlPhaseStartCleanup
       rlRun "rm /etc/modules-load.d/ipip.conf /usr/bin/systemd-modules-load-test.py"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
