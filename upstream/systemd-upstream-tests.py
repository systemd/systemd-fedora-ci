#!/usr/bin/env python3
# SPDX-License-Identifier: LGPL-2.1+
# systemd-tests

import os
import sys
import unittest
import subprocess

path = '/usr/lib/systemd/tests'

# Add tests needs to be skipped.
skip_tests = ['test-barrier', 'test-boot-timestamps', 'test-bus-chat', 'test-bus-cleanup', 'test-bus-gvariant', 'test-bus-marshal', 'test-bus-match'
              'test-bus-track', 'test-catalog', 'test-bus-match', 'test-bus-track']

class TestSequense(unittest.TestCase):
    pass

def test_generator(f):
    def test(self):
        subprocess.check_output([os.path.join(path, f)])
    return test

if __name__ == '__main__':
    dirs = os.listdir(path)

    for f in dirs:
        if f not in skip_tests:
              if os.path.isfile(os.path.join(path, f)):
                  test_name = f.replace("-", "_")
                  test = test_generator(f)
                  setattr(TestSequense, test_name, test)

    unittest.main()
