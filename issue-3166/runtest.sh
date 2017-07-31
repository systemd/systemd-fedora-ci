#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1+
# ~~~
#   runtest.sh of https://github.com/systemd/systemd/issues/3166
#   Description: Service doesn't enter the "failed" state
#
#   Author: Susant Sahani <susant@redhat.com>
#   Copyright (c) 2017 Red Hat, Inc.
# ~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

# Inspiration from https://github.com/systemd/systemd/issues/3166

PACKAGE="systemd"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE

        # setup the testsuite service
        rlRun -s "cat >/etc/systemd/system/testsuite.service <<EOF
[Unit]
Description=Testsuite service
After=multi-user.target

[Service]
ExecStart=/test-fail-on-restart.sh
Type=oneshot
EOF"

        rlRun -s "cat >/etc/systemd/system/fail-on-restart.service <<EOF
[Unit]
Description=Fail on restart

[Service]
Type=simple
ExecStart=/bin/false
Restart=always
EOF"

        rlRun -s "cat >/usr/bin/test-fail-on-restart.sh <<'EOF'
#!/bin/bash -x

systemctl start fail-on-restart.service
active_state=$(systemctl show --property ActiveState fail-on-restart.service)
while [[ "$active_state" == "ActiveState=activating" || "$active_state" == "ActiveState=active" ]]; do
    sleep 1
    active_state=$(systemctl show --property ActiveState fail-on-restart.service)
done
systemctl is-failed fail-on-restart.service || exit 1
touch /tmp/oktestok
EOF"
        rlRun "chmod 0755 /usr/bin/test-fail-on-restart.sh"
        rlRun "systemctl daemon-reload"
    rlPhaseEnd

    rlPhaseStartTest
	rlLog "Service doesn't enter the failed state"

	rlLog "starting testsuite.service"
     	rlRun "systemctl start testsuite.service" 1
        rlAssertNotExists "/tmp/testok"
    rlPhaseEnd

    rlPhaseStartCleanup
       rlRun "rm /etc/systemd/system/testsuite.service /usr/bin/test-fail-on-restart.sh /etc/systemd/system/fail-on-restart.service"
       rlRun "systemctl daemon-reload"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
