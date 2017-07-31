#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1+
#~~~~
#   runtest.sh of rlimits
#   Description: Test for resource limits
#
#   Author: Susant Sahani <susant@redhat.com>
#   Copyright (c) 2017 Red Hat, Inc.
# ~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

# Inspiration from https://github.com/systemd/systemd/tree/master/test/TEST-05-RLIMITS

PACKAGE="systemd"
VERSION="$(systemctl --version | grep systemd |  awk '{print $2}')"

SystemConf="/etc/systemd/system.conf"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE
        rlRun "rlFileBackup $SystemConf"

	rlRun "cp system.conf /etc/systemd/system.conf"
        rlRun "systemctl daemon-reload"
    rlPhaseEnd

    rlPhaseStartTest
        rlLog "Resource limits test system wide"

        rlRun "[[ \"$(systemctl show -p DefaultLimitNOFILE)\" = \"DefaultLimitNOFILE=16384\" ]]"

        if [ "$VERSION" -gt "219" ]
        then
            rlRun "[[ \"$(systemctl show -p DefaultLimitNOFILESoft)\" = \"DefaultLimitNOFILESoft=10000\" ]]"
        fi
    rlPhaseEnd

    rlPhaseStartTest
        rlLog "Resource limits test for service"

        rlRun "cp test-rlimits.service /etc/systemd/system/"
        rlRun "cp test-rlimits.sh /usr/bin/"
        rlRun "systemctl daemon-reload"

        rlLog "Starting testsuite.service"
        rlRun "systemctl start test-rlimits.service"
        rlRun "systemctl status test-rlimits.service" 3 "Status"

        rlRun "[[ "$(systemctl show -p LimitNOFILESoft testsuite.service)" = "LimitNOFILESoft=10000" ]]"
        rlRun "[[ "$(systemctl show -p LimitNOFILE testsuite.service)" = "LimitNOFILE=16384" ]]"

        rlAssertExists "/var/run/testok"
        rlRun "rm /var/run/testok /usr/bin/test-rlimits.sh /etc/systemd/system/test-rlimits.service"
    rlPhaseEnd

    rlPhaseStartCleanup
       rlRun "rlFileRestore"
       rlRun "systemctl daemon-reload"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
