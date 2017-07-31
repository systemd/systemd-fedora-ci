#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1+
# ~~~
#   runtest.sh of https://github.com/systemd/systemd/issues/1981
#   Description: Test for timer segfault
#
#   Author: Susant Sahani <susant@redhat.com>
#   Copyright (c) 2017 Red Hat, Inc.
# ~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

# Inspiration from https://github.com/systemd/systemd/tree/master/test/TEST-07-ISSUE-1981

PACKAGE="systemd"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE

        rlRun -s "cat >/etc/systemd/system/testsuite.service <<EOF
[Unit]
Description=Testsuite service
After=multi-user.target

[Service]
ExecStart=/usr/bin/test-segfault.sh
Type=oneshot
EOF"
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
       rlRun "rm  -rf etc/systemd/system/my.timer.d"
       rlRun "systemctl daemon-reload"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
