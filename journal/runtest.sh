#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1+
# ~~~
#   runtest.sh of journald
#   Description: Test for journal
#
#   Author: Susant Sahani<susant@redhat.com>
#   Copyright (c) 2017 Red Hat, Inc.
# ~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

# Inspiration from https://github.com/systemd/systemd/tree/master/test/TEST-04-JOURNAL

PACKAGE="systemd"

rlJournalStart
    rlPhaseStartSetup
    rlAssertRpm $PACKAGE

        rlRun -s "cat >/etc/systemd/system/forever-print-hola.service <<EOF
[Unit]
Description=ForeverPrintHola service

[Service]
Type=simple
ExecStart=/bin/sh -x -c 'while :; do printf "Hola\n" || touch /i-lose-my-logs; sleep 1; done'
EOF"

rlRun -s "cat >/etc/systemd/system/testsuite.service <<EOF
[Unit]
Description=Testsuite service
After=multi-user.target

[Service]
ExecStart=/usr/bin/test-journal.sh
Type=oneshot
EOF"
        rlRun "cp -v test-journal.sh /usr/bin/"
        rlRun "systemctl daemon-reload"
    rlPhaseEnd

    rlPhaseStartTest
	rlLog "status journald test"

	rlLog "starting forever-print-hola.service"
     	rlRun "systemctl start forever-print-hola.service"

        rlLog "starting testsuite.service"
     	rlRun "systemctl start testsuite.service"

        rlAssertExists "/tmp/testok"
    rlPhaseEnd

    rlPhaseStartCleanup

       rlRun "rm /tmp/testok"
       rlRun "rm /etc/systemd/system/forever-print-hola.service /etc/systemd/system/testsuite.service /usr/bin/test-journal.sh"

       rlRun "systemctl daemon-reload"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
