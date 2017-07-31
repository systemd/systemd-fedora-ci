#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1+
# ~~~
#   runtest.sh of systemd-resolved
#   Description: Test for systemd-resolved
# ~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="systemd"
ResolvedConf="/etc/systemd/resolved.conf"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE
        rlRun "rlFileBackup $ResolvedConf"
         rlRun "cp systemd-resolve-tests.py /usr/bin"
    rlPhaseEnd

    rlPhaseStartTest
         rlRun "/usr/bin/python3 /usr/bin/systemd-resolve-tests.py"
     rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "rlFileRestore"
        rlRun "rm /usr/bin/systemd-resolve-tests.py"
        rlRun "systemctl restart systemd-resolved"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
