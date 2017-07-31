#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1+
# ~~~
#   runtest.sh of /CoreOS/systemd/Sanity/hostnamectl
#   Description: Test for hostnamectl

#   Author: Branislav Blaskovic <bblaskov@redhat.com>
#   Copyright (c) 2015 Red Hat, Inc.
# ~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

# Inspiration from https://bazaar.launchpad.net/~ubuntu-branches/ubuntu/wily/systemd/wily/view/head:/debian/tests/hostnamed

PACKAGE="systemd"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE
        rlRun "ORIG_HOST=`cat /etc/hostname`"
        rlRun -s "hostnamectl"
    rlPhaseEnd

    rlPhaseStartTest
        rlLog "status test"
        rlAssertGrep "Static hostname: $ORIG_HOST" "$rlRun_LOG"

        rlLog "set-hostname test"
        rlRun "hostnamectl set-hostname testhostname"
        rlAssertGrep "testhostname" "/etc/hostname"
        rlRun -s "hostnamectl"
        rlAssertGrep "Static hostname: testhostname" "$rlRun_LOG"

        rlLog "set-location test"
        rlRun "hostnamectl set-location Pune,India"
        rlRun "hostnamectl > /tmp/hostnamectl_test"
        rlAssertGrep "Pune,India" "/tmp/hostnamectl_test"
        rlRun "hostnamectl set-location ''"

        rlLog "set-deployment test"
        rlRun "hostnamectl set-deployment development"
        rlRun "hostnamectl > /tmp/hostnamectl_test"
        rlAssertGrep "development" "/tmp/hostnamectl_test"
        rlRun "hostnamectl set-deployment ''"

        rlLog "set-chassis test"
        rlRun "hostnamectl set-chassis server"
        rlRun "hostnamectl > /tmp/hostnamectl_test"
        rlAssertGrep "server" "/tmp/hostnamectl_test"
        rlRun "hostnamectl set-chassis ''"

        rlLog "set-icon-name test"
        rlRun "hostnamectl set-icon-name computer-laptop-test"
        rlRun "hostnamectl > /tmp/hostnamectl_test"
        rlAssertGrep "computer-laptop-test" "/tmp/hostnamectl_test"
        rlRun "hostnamectl set-icon-name ''"

    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "hostnamectl set-hostname $ORIG_HOST"
        rlRun -s "hostnamectl"
        rlAssertGrep "Static hostname: $ORIG_HOST" "$rlRun_LOG"
        rlRun "rm /tmp/hostnamectl_test"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
