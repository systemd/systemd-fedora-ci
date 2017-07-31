#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1+
# ~~~
#   runtest.sh of Timer Unit
#   Description: Test for systemd timers
# ~~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="systemd"
SYSTEMD_CI_DIR="/var/run/systemd-ci"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE
	rlRun "setenforce 0" 0,1
        rlRun "mkdir -p $SYSTEMD_CI_DIR"
        rlRun "cp timertest.service timertest.timer  $SYSTEMD_CI_DIR"
        rlRun "cp systemd-timer-tests.py /usr/bin"
    rlPhaseEnd

    rlPhaseStartTest
	rlLog "Starting timers test"
        rlRun "/usr/bin/python3 systemd-timer-tests.py"
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "rm -rf $SYSTEMD_CI_DIR /usr/bin/systemd-timer-tests.py"
	rlRun "setenforce 1" 0,1
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
