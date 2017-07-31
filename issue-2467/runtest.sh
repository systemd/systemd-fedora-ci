#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1+
# ~~~
#   runtest.sh of https://github.com/systemd/systemd/issues/2467
#   Description: don't start services every few ms if condition fails.
#
#   Author: Susant Sahani <susant@redhat.com>
#   Copyright (c) 2018 Red Hat, Inc.
# ~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="systemd"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE

        rlRun -s "cat >/etc/systemd/system/testsuite.service <<EOF
[Unit]
Description=Testsuite service
After=multi-user.target

[Service]
Type=oneshot
StandardOutput=tty
StandardError=tty
ExecStart=/bin/sh -e -x -c 'rm -f /tmp/nonexistent; systemctl start test.socket; echo a | nc -U /run/test.ctl; >/tmp/testok'
TimeoutStartSec=10s
EOF"

        rlRun -s "cat >/etc/systemd/system/test.socket <<EOF
[Socket]
ListenStream=/run/test.ctl
EOF"

         rlRun -s "cat >/etc/systemd/system/test.service <<EOF
[Unit]
Requires=test.socket
ConditionPathExistsGlob=/tmp/nonexistent

[Service]
ExecStart=/bin/true
EOF"
        rlRun "systemctl daemon-reload"
    rlPhaseEnd

    rlPhaseStartTest
	rlLog "Don't start services every few ms if condition fails."

	rlLog "starting testsuite.service"
        rlRun "systemctl start testsuite.service" 1
        rlAssertNotExists "/tmp/testok"
    rlPhaseEnd

    rlPhaseStartCleanup
       rlRun "rm /etc/systemd/system/test.service /etc/systemd/system/test.socket /etc/systemd/system/testsuite.service"
       rlRun "systemctl daemon-reload"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
rlJournalPrintText
