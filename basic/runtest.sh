#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1+
# ~~~
#   runtest.sh of basic systemd test
#   Description: Basic systemd setup
# ~~~
# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="systemd"

rlJournalStart
    rlPhaseStartSetup
    rlAssertRpm $PACKAGE
    rlPhaseEnd

    rlPhaseStartTest
    rlLog "Basic systemd setup"

    rlRun "systemctl --state=failed --no-legend --no-pager > /tmp/failed ; echo OK > /tmp/testok"
    rlAssertNotGrep "failed" "/tmp/testok"
    rlPhaseEnd

    rlPhaseStartCleanup
    rlRun "rm /tmp/testok /tmp/failed"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
