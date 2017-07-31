#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1+
# ~~~
#   runtest.sh of /CoreOS/systemd/Sanity/tmpfiles
#   Description: Test for (Systemd-tmpfiles does not set owner/group defined)
#
#   Author: Branislav Blaskovic <bblaskov@redhat.com>
#   Some parts based on script by: Jakub Martisko <jamartis@redhat.com>
#   Copyright (c) 2016 Red Hat, Inc.
#
# ~~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="systemd"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE
        rlRun "TmpDir=\$(mktemp -d)" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"

        rlRun "useradd foo"
        rlRun "groupadd bar"
    rlPhaseEnd

    rlPhaseStartTest "test tmpfiles: enforce ordering when executing lines"

cat <<\EOF > /etc/tmpfiles.d/hello.conf
D /run/hello  1777 foo bar -
f /run/hello/hello.test  1777 root bar -
z /run/hello/hello.test 1777 root root - -
EOF

        rlRun "systemd-tmpfiles --create"
        rlRun -s "ls -al /run/hello/"
        rlAssertGrep "foo.*bar.*\.$" $rlRun_LOG
        rlAssertGrep "root.*root.*hello.test$" $rlRun_LOG
    rlPhaseEnd

    rlPhaseStartTest "test tmpfiles: don't follow symlinks when adjusting ACLs, fille attributes, access modes or ownership"

cat <<\EOF > /etc/tmpfiles.d/hello2.conf
D /run/hello2  1777 foo bar -
f /run/hello2/hello2.test  1777 root bar -
L+ /run/hello2/hello2.link - root bar - /run/hello2/hello2.test
z /run/hello2/hello2.test 1777 root root - -
z /run/hello2/hello2.link - foo bar - -
EOF

        rlRun "systemd-tmpfiles --create"
        rlRun -s "ls -al  /run/hello2/"
        rlAssertGrep "root.*root.* hello2.test$" $rlRun_LOG
        rlAssertGrep "foo.*bar.* hello2.link -> /run/hello2/hello2.test$" $rlRun_LOG
    rlPhaseEnd

        rlPhaseStartTest "test tmpfiles: create FIFO, char and block devices"

cat <<\EOF > /etc/tmpfiles.d/hello3.conf
D /run/hello3  1777 foo bar -
p /run/hello3/hello3.fifo   1777 foo bar -
c /run/hello3/hello3.char   -    foo bar - 50:1
b /run/hello3/hello3.block  -    foo bar - 51:1
EOF

        rlRun "systemd-tmpfiles --create"
        rlRun -s "ls -l  /run/hello3/"
        rlAssertGrep "hello3.fifo" $rlRun_LOG
        rlAssertGrep "hello3.char" $rlRun_LOG
        rlAssertGrep "hello3.block" $rlRun_LOG

        rlRun -s "[[ -p "/run/hello3/hello3.fifo" ]]"
        rlRun -s "[[ -c "/run/hello3/hello3.char" ]]"
        rlRun -s "[[ -b "/run/hello3/hello3.block" ]]"

        rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "popd"
        rlRun "userdel -r foo"
        rlRun "groupdel bar"
        rlRun "rm -r $TmpDir /etc/tmpfiles.d/hello*.conf" 0 "Removing tmp directory"
        rlRun "rm -rf /run/hello*"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
