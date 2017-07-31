#!/usr/bin/env python3
# SPDX-License-Identifier: LGPL-2.1+
# systemd-networkd tests

import os
import sys
import unittest
import subprocess
import time
import shutil
import signal
import socket
import threading

network_unit_file_path='/var/run/systemd/network'
networkd_ci_path='/var/run/networkd-ci'

class Utilities():

    def link_exits(self, link):
        return os.path.exists(os.path.join('/sys/class/net', link))

    def link_remove(self, links):
        for link in links:
            if os.path.exists(os.path.join('/sys/class/net', link)):
                subprocess.call(['ip', 'link', 'del', 'dev', link])

    def copy_unit_to_networkd_unit_path(self, *units):
        for unit in units:
            shutil.copy(os.path.join(networkd_ci_path, unit), network_unit_file_path)

    def remove_unit_from_networkd_path(self, units):
        for unit in units:
            if (os.path.exists(os.path.join(network_unit_file_path, unit))):
                os.remove(os.path.join(network_unit_file_path, unit))


    def start_networkd(self):
        subprocess.call(['systemctl', 'stop', 'systemd-networkd'])
        time.sleep(1)
        subprocess.call(['systemctl', 'start', 'systemd-networkd'])
        time.sleep(5)

class NetworkdWaitOnlineTests(unittest.TestCase, Utilities):

    links =['dummy99']

    units = ['25-dummy.netdev', 'dummy99.network']

    def setUp(self):
        self.link_remove(self.links)

    def tearDown(self):
        self.link_remove(self.links)
        self.remove_unit_from_networkd_path(self.units)

    def test_dummy_link_appears(self):
        self.copy_unit_to_networkd_unit_path('25-dummy.netdev', 'dummy99.network')
        self.start_networkd()

        self.assertTrue(self.link_exits('dummy99'))
        subprocess.call(['/lib/systemd/systemd-networkd-wait-online', '-i', 'dummy99'])

    def test_dummy_timeout(self):
        self.copy_unit_to_networkd_unit_path('25-dummy.netdev')
        self.start_networkd()

        self.assertTrue(self.link_exits('dummy99'))
        subprocess.call(['/lib/systemd/systemd-networkd-wait-online', '--timeout=5', '--interface=dummy99'])

if __name__ == '__main__':
    unittest.main(testRunner=unittest.TextTestRunner(stream=sys.stdout,
                                                     verbosity=3))
