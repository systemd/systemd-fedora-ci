#!/usr/bin/env python3
# SPDX-License-Identifier: LGPL-2.1+
# systemd-modules-load tests

import os
import sys
import unittest
import subprocess

class SystemdModulesLoadTests(unittest.TestCase):
    def tearDown(self):

        subprocess.check_output(['rmmod','ipip'])

    def test_ipip_module_getting_loaded(self):

        subprocess.check_output(['/usr/lib/systemd/systemd-modules-load','/etc/modules-load.d/ipip.conf'])
        output=subprocess.check_output(['modinfo','ipip']).rstrip().decode('utf-8')
        print(output)

if __name__ == '__main__':
    unittest.main(testRunner=unittest.TextTestRunner(stream=sys.stdout,
                                                     verbosity=3))
