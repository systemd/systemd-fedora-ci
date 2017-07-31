#!/usr/bin/env python3
# SPDX-License-Identifier: LGPL-2.1+
# systemd.socket tests

import os
import sys
import unittest
import subprocess
import shutil
import psutil
import socket

systemd_unit_path='/var/run/systemd/system'
systemd_ci_path='/var/run/sytemd-ci-socket'

class utilities():
    def find_port_open(self, port):

        connections = psutil.net_connections()
        for c in connections:
            if port == c.laddr.port:
                return True

        return False

    def copy_file_from_ci_dir_to_systemd_unit_path(self, unit):
        shutil.copy(os.path.join(systemd_ci_path, unit + '.socket'), systemd_unit_path)
        shutil.copy(os.path.join(systemd_ci_path, 'test.service'), os.path.join(systemd_unit_path, unit + '.service'))

        subprocess.check_output(['systemctl', 'daemon-reload'])

    def remove_unit_from_systemd_unit_path(self, unit):
        os.remove(os.path.join(systemd_unit_path, unit + '.service'))
        os.remove(os.path.join(systemd_unit_path, unit + '.socket'))

        subprocess.check_output(['systemctl', 'daemon-reload'])

class SystemdSocketTests(unittest.TestCase, utilities):
    def test_socket_stream(self):

        self.copy_file_from_ci_dir_to_systemd_unit_path('test-socket-stream')
        subprocess.check_output(['systemctl', 'start', 'test-socket-stream.socket'])

        output = subprocess.check_output(['systemctl', 'status', 'test-socket-stream.socket']).rstrip().decode('utf-8')
        print(output)

        self.assertTrue(self.find_port_open(9999))

        subprocess.check_output(['systemctl', 'stop', 'test-socket-stream.socket'])
        self.remove_unit_from_systemd_unit_path('test-socket-stream')

    def test_socket_datagram(self):

        self.copy_file_from_ci_dir_to_systemd_unit_path('test-socket-datagram')
        subprocess.check_output(['systemctl', 'start', 'test-socket-datagram.socket'])

        output = subprocess.check_output(['systemctl', 'status', 'test-socket-datagram.socket']).rstrip().decode('utf-8')
        print(output)

        self.assertTrue(self.find_port_open(9999))

        subprocess.check_output(['systemctl', 'stop', 'test-socket-datagram.socket'])
        self.remove_unit_from_systemd_unit_path('test-socket-datagram')

    def test_socket_sequential(self):

        self.copy_file_from_ci_dir_to_systemd_unit_path('test-socket-sequential')
        subprocess.check_output(['systemctl', 'start', 'test-socket-sequential.socket'])

        output = subprocess.check_output(['systemctl', 'status', 'test-socket-sequential.socket']).rstrip().decode('utf-8')
        print(output)

        self.assertTrue(os.path.exists('/var/run/test-sequential-packet.socket'))

        subprocess.check_output(['systemctl', 'stop', 'test-socket-sequential.socket'])
        self.remove_unit_from_systemd_unit_path('test-socket-sequential')

    def test_socket_fifo(self):

        self.copy_file_from_ci_dir_to_systemd_unit_path('test-socket-fifo')
        subprocess.check_output(['systemctl', 'start', 'test-socket-fifo.socket'])

        output = subprocess.check_output(['systemctl', 'status', 'test-socket-fifo.socket']).rstrip().decode('utf-8')
        print(output)

        self.assertTrue(os.path.exists('/var/run/test-fifo'))

        subprocess.check_output(['systemctl', 'stop', 'test-socket-fifo.socket'])
        self.assertFalse(os.path.exists('/var/run/test-fifo'))

        self.remove_unit_from_systemd_unit_path('test-socket-fifo')

    def test_socket_sctp(self):

        self.copy_file_from_ci_dir_to_systemd_unit_path('test-protocol-sctp')
        subprocess.check_output(['systemctl', 'start', 'test-protocol-sctp.socket'])

        output = subprocess.check_output(['systemctl', 'status', 'test-protocol-sctp.socket']).rstrip().decode('utf-8')
        print(output)

        output = subprocess.check_output(['netstat', '-S']).rstrip().decode('utf-8')
        print(output)

        self.assertRegex(output, '9998')

        subprocess.check_output(['systemctl', 'stop', 'test-protocol-sctp.socket'])
        self.remove_unit_from_systemd_unit_path('test-protocol-sctp')

    def test_socket_udplite(self):

        self.copy_file_from_ci_dir_to_systemd_unit_path('test-protocol-udplite')
        subprocess.check_output(['systemctl', 'start', 'test-protocol-udplite.socket'])

        output = subprocess.check_output(['systemctl', 'status', 'test-protocol-udplite.socket']).rstrip().decode('utf-8')
        print(output)

        output = subprocess.check_output(['lsof', '-p', '1']).rstrip().decode('utf-8')
        for part in output.split('\n'):
            if 'UDPLITE' in part:
                self.assertRegex(part, '9998')
                self.assertRegex(part, 'UDPLITE')

        subprocess.check_output(['systemctl', 'stop', 'test-protocol-udplite.socket'])
        self.remove_unit_from_systemd_unit_path('test-protocol-udplite')

    def test_socket_bindipv6only(self):

        self.copy_file_from_ci_dir_to_systemd_unit_path('test-socket-stream-ipv6only')
        subprocess.check_output(['systemctl', 'start', 'test-socket-stream-ipv6only.socket'])

        output = subprocess.check_output(['systemctl', 'status', 'test-socket-stream-ipv6only.socket']).rstrip().decode('utf-8')
        print(output)

        output = subprocess.check_output(['lsof', '-p', '1']).rstrip().decode('utf-8')
        self.assertTrue(self.find_port_open(9990))

        connections = psutil.net_connections(kind='tcp4')
        for c in connections:
            if 9990 == c.laddr.port:
                self.assertFalse(0)

        subprocess.check_output(['systemctl', 'stop', 'test-socket-stream-ipv6only.socket'])
        self.remove_unit_from_systemd_unit_path('test-socket-stream-ipv6only')

    def test_socket_netlink(self):

        self.copy_file_from_ci_dir_to_systemd_unit_path('test-socket-netlink')
        subprocess.check_output(['systemctl', 'start', 'test-socket-netlink.socket'])

        output = subprocess.check_output(['systemctl', 'status', 'test-socket-netlink.socket']).rstrip().decode('utf-8')
        print(output)

        output = subprocess.check_output(['systemctl', '--property', 'ListenNetlink', 'list-sockets']).rstrip().decode('utf-8')
        print(output)
        self.assertRegex(output, 'test-socket-netlink.socket')

        subprocess.check_output(['systemctl', 'stop', 'test-socket-netlink.socket'])
        self.remove_unit_from_systemd_unit_path('test-socket-netlink')

    def test_socket_vsock(self):

        self.copy_file_from_ci_dir_to_systemd_unit_path('test-socket-vsock')
        subprocess.check_output(['systemctl', 'start', 'test-socket-vsock.socket'])

        output = subprocess.check_output(['systemctl', 'status', 'test-socket-vsock.socket']).rstrip().decode('utf-8')
        print(output)

        output = subprocess.check_output(['systemctl', '--property', 'ListenStream', 'list-sockets']).rstrip().decode('utf-8')
        print(output)

        self.assertRegex(output, 'test-socket-vsock.socket')
        self.assertRegex(output, 'vsock:2:1234')

        subprocess.check_output(['systemctl', 'stop', 'test-socket-vsock.socket'])
        self.remove_unit_from_systemd_unit_path('test-socket-vsock')

if __name__ == '__main__':
    unittest.main(testRunner=unittest.TextTestRunner(stream=sys.stdout,
                                                     verbosity=3))
