#!/usr/bin/env python3
# SPDX-License-Identifier: LGPL-2.1+
# systemd.timer tests
import os
import sys
import unittest
import subprocess
import shutil
import time

system_unit_path='/var/run/systemd/system'
systemd_ci_path='/var/run/systemd-ci'
timer_test_file='/var/run/systemd-ci/timer-test'

class SystemdUtility():

    def copy_file_from_ci_dir_to_systemd_unit_path(self, unit):
        shutil.copy(os.path.join(systemd_ci_path, unit + '.timer'), system_unit_path)
        shutil.copy(os.path.join(systemd_ci_path, unit + '.service'), os.path.join(system_unit_path, unit + '.service'))

        subprocess.call(['systemctl', 'daemon-reload'])
        time.sleep(1)

    def remove_unit_from_systemd_unit_path(self, unit):
        os.remove(os.path.join(system_unit_path, unit + '.service'))
        os.remove(os.path.join(system_unit_path, unit + '.timer'))

        subprocess.check_output(['systemctl', 'daemon-reload'])

class SystemdTimerTests(unittest.TestCase, SystemdUtility):
    def setUp(self):
        self.copy_file_from_ci_dir_to_systemd_unit_path('timertest')

    def tearDown(self):
        subprocess.check_output(['systemctl', 'stop', 'timertest.timer'])
        self.remove_unit_from_systemd_unit_path('timertest')

    def test_timer_on_active(self):
        subprocess.check_output(['systemctl', 'start', 'timertest.timer'])

        output = subprocess.check_output(['systemctl', 'status', 'timertest.timer']).rstrip().decode('utf-8')
        print(output)

        output = subprocess.check_output(['systemctl', 'list-timers']).rstrip().decode('utf-8')
        self.assertRegex(output, 'timertest.service')

        time.sleep(5)

        output = subprocess.check_output(['systemctl', 'status', 'timertest.service']).rstrip().decode('utf-8')
        print(output)
        self.assertRegex(output, 'hello timer-test')

if __name__ == '__main__':
    unittest.main(testRunner=unittest.TextTestRunner(stream=sys.stdout,
                                                     verbosity=3))
