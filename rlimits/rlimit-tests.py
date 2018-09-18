#!/usr/bin/env python3
# SPDX-License-Identifier: LGPL-2.1+
# rlimit tests

import os
import sys
import unittest
import subprocess

class SystemdResouceLimitTests(unittest.TestCase):

    def test_resource_limits_test_system_wide(self):
        output=subprocess.check_output(['systemctl', 'show', '-p', 'DefaultLimitNOFILE']).strip().decode('utf-8')
        print(output)
        self.assertRegex(output, 'DefaultLimitNOFILE=16384')

        output=subprocess.check_output(['systemctl', 'show', '-p', 'DefaultLimitNOFILESoft']).strip().decode('utf-8')
        self.assertRegex(output, 'DefaultLimitNOFILESoft=10000')
        print(output)

    def test_resource_limits_test_service(self):
        subprocess.call(['systemctl', 'start', 'test-rlimits.service'])
        output=subprocess.check_output(['systemctl', 'status', 'test-rlimits.service']).strip().decode('utf-8')
        print(output)

        output=subprocess.check_output(['systemctl', 'show', '-p', 'LimitNOFILESoft', 'test-rlimits.service']).strip().decode('utf-8')
        print(output)
        self.assertRegex(output, 'LimitNOFILESoft=10000')

        output=subprocess.check_output(['systemctl', 'show', '-p', 'LimitNOFILE', 'test-rlimits.service']).strip().decode('utf-8')
        print(output)
        self.assertRegex(output, 'LimitNOFILE=16384')

        subprocess.call(['systemctl', 'stop', 'test-rlimits.service'])



if __name__ == '__main__':
    unittest.main(testRunner=unittest.TextTestRunner(stream=sys.stdout,
                                                     verbosity=3))
