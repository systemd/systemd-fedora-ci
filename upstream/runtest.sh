#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1+
# ~~~
#   runtest.sh of systemd-upstream-tests
#   Description: Test for systemd-upstream-tests
# ~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE_SYSTEMD="systemd"
PACKAGE_SYSTEMD_TESTS="systemd-tests"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE_SYSTEMD
        rlAssertRpm $PACKAGE_SYSTEMD_TESTS

        rlRun "cp systemd-upstream-tests.py /usr/bin/"
    rlPhaseEnd

    rlPhaseStartTest
        rlLog "systemd-upstream-tests related test"
        rlRun "/usr/bin/python3 /usr/bin/systemd-upstream-tests.py"
    rlPhaseEnd

    rlPhaseStartCleanup
       rlRun "rm /usr/bin/systemd-upstream-tests.py"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
