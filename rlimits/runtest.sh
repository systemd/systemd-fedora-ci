#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1+
#~~~~
#   runtest.sh of rlimits
#   Description: Test for resource limits
# ~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="systemd"
SystemConf="/etc/systemd/system.conf"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE
        rlRun "rlFileBackup $SystemConf"

	rlRun "cp system.conf /etc/systemd/system.conf"
        rlRun "cp rlimit-tests.py test-rlimits.sh /usr/bin"
        rlRun "cp test-rlimits.service /var/run/systemd/system"
        rlRun "systemctl daemon-reload"
    rlPhaseEnd

    rlPhaseStartTest
        rlRun "/usr/bin/python3 /usr/bin/rlimit-tests.py"
    rlPhaseEnd

    rlPhaseStartCleanup
       rlRun "rm /usr/bin/rlimit-tests.py /usr/bin/test-rlimits.sh /var/run/systemd/system/test-rlimits.service"
       rlRun "systemctl daemon-reload"
       rlRun "rlFileRestore"
    rlPhaseEnd

rlJournalPrintText
rlJournalEnd

rlGetTestState
