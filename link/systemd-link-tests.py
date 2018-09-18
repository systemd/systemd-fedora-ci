#!/usr/bin/env python3
# SPDX-License-Identifier: LGPL-2.1+
# systemd-link tests

import os
import sys
import unittest
import subprocess
import shutil

systemd_unit_path='/var/run/systemd/network'
systemd_ci_path='/var/run/sytemd-ci'

class LinkUtility():

    def setup_veth(self):
        subprocess.check_output(['ip', 'link', 'add', 'veth99', 'type', 'veth', 'peer', 'name', 'peer99'])

        self.link_exits('veth99')

        subprocess.check_output(['ip', 'link', 'set', 'veth99', 'address', '00:01:02:aa:bb:cc'])
        subprocess.check_output(['ip', 'link', 'set', 'dev', 'veth99', 'up'])
        subprocess.check_output(['ip', 'link', 'set', 'dev', 'peer99', 'up'])

    def tear_down_veth(self):
        subprocess.check_output(['ip', 'link', 'del', 'veth99'])

    def read_link_attr(self, link, attribute):

        with open(os.path.join(os.path.join('/sys/class/net/', link), attribute)) as f:
            return f.readline().strip()

    def link_exits(self, link):
        return os.path.exists(os.path.join('/sys/class/net', link))

    def copy_file_from_ci_dir_to_systemd_unit_path(self, unit):
        shutil.copy(os.path.join(systemd_ci_path, unit), systemd_unit_path)

    def remove_unit_from_systemd_unit_path(self, units):
        for unit in units:
            if os.path.exists(os.path.join(systemd_unit_path, unit)):
                os.remove(os.path.join(systemd_unit_path, unit))

class SystemdLinkTests(unittest.TestCase, LinkUtility):
    units = ['00-test.link', '00-test1.link']

    def setUp(self):
        self.setup_veth()

    def tearDown(self):
        self.tear_down_veth()
        self.remove_unit_from_systemd_unit_path(self.units)

    def test_mtu_speed_offload(self):
        '''Link test: Speed, MTU, tcp-segmentation-offload generic-segmentation-offload generic-receive-offload '''

        self.copy_file_from_ci_dir_to_systemd_unit_path('00-test.link')

        subprocess.call(['udevadm', 'test-builtin', 'net_setup_link', '/sys/class/net/veth99'])
        self.assertEqual('10000', self.read_link_attr('veth99', 'speed'))
        self.assertEqual('1280', self.read_link_attr('veth99', 'mtu'))

        output=subprocess.check_output(['ethtool', '-k', 'veth99']).rstrip().decode('utf-8')
        print(output)
        self.assertRegex(output, 'tcp-segmentation-offload: on')
        self.assertRegex(output, 'generic-segmentation-offload: on')
        self.assertRegex(output, 'generic-receive-offload: on')

    def test_mac_alias(self):
        '''systemd link test: MACAddress=, Alias= '''
        self.copy_file_from_ci_dir_to_systemd_unit_path('00-test1.link')

        subprocess.call(['udevadm', 'test-builtin', 'net_setup_link', '/sys/class/net/veth99'])

        output=subprocess.check_output(['ip', '-d', 'link', 'show', 'veth99']).rstrip().decode('utf-8')
        print(output)

        self.assertEqual('testalias99', self.read_link_attr('veth99', 'ifalias'))
        self.assertEqual('00:01:02:aa:bb:cd', self.read_link_attr('veth99', 'address'))

if __name__ == '__main__':
    unittest.main(testRunner=unittest.TextTestRunner(stream=sys.stdout,
                                                     verbosity=3))
