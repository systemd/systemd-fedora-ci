#!/bin/bash -x

systemctl start fail-on-restart.service

active_state=$(systemctl show --property ActiveState fail-on-restart.service)
while [[ "$active_state" == "ActiveState=activating" || "$active_state" == "ActiveState=active" ]]; do
    sleep 1
    active_state=$(systemctl show --property ActiveState fail-on-restart.service)
done

systemctl is-failed fail-on-restart.service || exit 1

touch /var/run/testok
