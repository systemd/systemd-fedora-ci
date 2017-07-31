#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1+
# ~~~
#   runtest.sh of /CoreOS/systemd/Sanity/localectl
#   Description: Test for localectl
#
#   Author: Branislav Blaskovic <bblaskov@redhat.com>
#   Copyright (c) 2015 Red Hat, Inc.
# ~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="systemd"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE
        rlFileBackup "/etc/locale.conf"
        rlFileBackup "/etc/vconsole.conf"
    rlPhaseEnd

    rlPhaseStartTest
        rlRun -s "localectl"
        rlAssertGrep "System Locale:" "$rlRun_LOG"

        rlRun "localectl set-locale LANG=C LC_CTYPE=en_US.UTF-8" 0 "Set some locale"
        rlRun -s "localectl"
        rlAssertGrep "LANG=C" "$rlRun_LOG"
        rlAssertGrep "LC_CTYPE=en_US.UTF-8" "$rlRun_LOG"

        rlRun "localectl set-locale LANG=C LC_CTYPE=sk_SK.UTF-8" 0 "Set some locale"
        rlRun -s "localectl"
        rlAssertGrep "LC_CTYPE=sk_SK.UTF-8" "$rlRun_LOG"

        rlRun "localectl set-x11-keymap et pc101" 0 "Set X11 default keyboard mapping"
        rlRun -s "localectl"
        rlAssertGrep "X11 Layout: et" "$rlRun_LOG"
        rlAssertGrep "X11 Model: pc101" "$rlRun_LOG"
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "localectl set-x11-keymap us"
        rlFileRestore
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd
rlGetTestState
