#!/bin/bash
#  SPDX-License-Identifier: LGPL-2.1+
# ~~~
#   runtest.sh of systemd link
#   Description: Test for systemd.link
# ~~~
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="systemd"
SYSTEMD_UNIT_PATH='/var/run/systemd/network'
SYSTEMD_CI_PATH='/var/run/sytemd-ci'

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE
        rlRun "mkdir -p $SYSTEMD_CI_PATH"
        rlRun "mkdir -p $SYSTEMD_UNIT_PATH"
        rlRun "cp 00-test1.link 00-test.link $SYSTEMD_CI_PATH"
        rlRun "cp systemd-link-tests.py /usr/bin"
    rlPhaseEnd

    rlPhaseStartTest
        rlRun "/bin/python3 /usr/bin/systemd-link-tests.py"
    rlPhaseEnd

    rlPhaseStartCleanup
       rlRun "rm -rf $SYSTEMD_CI_PATH /usr/bin/systemd-link-tests.py"
       rlRun "systemctl daemon-reload"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
