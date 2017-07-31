#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1+
# ~~~
#
#   runtest.sh of socket
#   Description: Test for socket
# ~~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="systemd"
SYSTEMD_CI_DIR="/var/run/sytemd-ci-socket"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE
        rlRun "setenforce 0" 0,1

        rlRun "mkdir -p $SYSTEMD_CI_DIR"
        rlRun "cp conf/*.socket conf/*.service $SYSTEMD_CI_DIR"
        rlRun "cp systemd-socket-tests.py /usr/bin"
        rlRun "systemctl daemon-reload"
    rlPhaseEnd

    rlPhaseStartTest
	rlLog "Starting Test Suite"
        rlRun "/usr/bin/python3 /usr/bin/systemd-socket-tests.py"
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "rm -rf /usr/bin/systemd-socket-tests.py $SYSTEMD_CI_DIR"
        rlRun "systemctl daemon-reload"
        rlRun "setenforce 1" 0,1
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
