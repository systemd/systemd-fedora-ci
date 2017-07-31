#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1+
# ~~~
#   runtest.sh of /CoreOS/systemd/Sanity/KillMode
#   Description: This test tests KillMode options for services
#
#   Author: Branislav Blaskovic <bblaskov@redhat.com>
#   Copyright (c) 2015 Red Hat, Inc.
# ~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="systemd"

function cleanup_cgroup()
{
    expect=$1
    while read pid
    do
        rlRun "ps $pid" $expect
        # cleanup
        kill -9 $pid
    done < /var/tmp/killmode.procs
}

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE
        rlRun "cp -v trapka* /usr/bin/"
        rlRun "TmpDir=\$(mktemp -d)" 0 "Creating tmp directory"
        rlRun "pushd $TmpDir"

        rlLog "Prepare tester.service with KillMode=none"
# Prepare files
cat >/usr/lib/systemd/system/tester.service <<EOF
[Unit]
Description=tester

[Service]
ExecStart=/usr/bin/tester
KillMode=none
EOF

        rlRun "echo '#!/bin/bash' > /usr/bin/tester"
        rlRun "echo \"sleep 1h\" >> /usr/bin/tester"
        rlRun "chmod +x /usr/bin/tester"

        rlRun "systemctl daemon-reload"

    rlPhaseEnd

    rlPhaseStartTest "KillMode none"
        rlRun "systemctl start tester.service"
        cp /sys/fs/cgroup/systemd/system.slice/tester.service/cgroup.procs /var/tmp/killmode.procs
        rlRun "systemctl status tester.service -l"
        rlRun "systemctl stop tester.service"
        cleanup_cgroup 0
    rlPhaseEnd

    rlPhaseStartTest "KillMode mixed"
        rlLog "Prepare tester.service with KillMode=mixed"
        rlRun "sed -i \"s/KillMode=none/KillMode=mixed/\" /usr/lib/systemd/system/tester.service"
        rlRun "sed -i \"s,/usr/bin/tester,/usr/bin/trapka,\" /usr/lib/systemd/system/tester.service"
            cat /usr/lib/systemd/system/tester.service
        rlRun "systemctl daemon-reload"

        rlRun "systemctl start tester.service"

        cp /sys/fs/cgroup/systemd/system.slice/tester.service/cgroup.procs /var/tmp/killmode.procs
        rlRun "systemctl status tester.service -l"
        rlRun "systemctl stop tester.service"
        rlRun -s "journalctl -u tester.service --no-pager"
        rlAssertGrep "Main process got SIGTERM" "$rlRun_LOG"
        rlAssertNotGrep "Sub process got SIGTERM" "$rlRun_LOG"
        cleanup_cgroup 1
    rlPhaseEnd

    rlPhaseStartCleanup
        rlRun "popd"
        rlRun "rm /usr/lib/systemd/system/tester.service /usr/bin/tester /usr/bin/trapka /usr/bin/trapka.sub /var/tmp/killmode.procs"
        rlRun "systemctl daemon-reload"
        rlRun "rm -r $TmpDir" 0 "Removing tmp directory"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd
rlGetTestState
