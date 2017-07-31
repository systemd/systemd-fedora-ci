#!/usr/bin/env python3
# SPDX-License-Identifier: LGPL-2.1+
# systemd-socket-activate tests

import os
import sys
import unittest
import subprocess
import socket

class SystemdSocketActivateTests(unittest.TestCase):
    def setUp(self):

        subprocess.check_output(['systemctl', 'start', 'systemd-socket-activate.service'])
        output = subprocess.check_output(['systemctl', 'status', 'systemd-socket-activate.service']).rstrip().decode('utf-8')
        print(output)

    def tearDown(self):

        subprocess.check_output(['systemctl', 'stop', 'systemd-socket-activate.service'])

    def test_simple_echo(self):

        client = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        client.connect(('0.0.0.0', 2000))
        client.send('hello'.encode('utf-8'))

        response = client.recv(4096)
        client.close()

        self.assertEqual(response.decode('utf-8'), 'hello')


if __name__ == '__main__':
    unittest.main(testRunner=unittest.TextTestRunner(stream=sys.stdout,
                                                     verbosity=3))
