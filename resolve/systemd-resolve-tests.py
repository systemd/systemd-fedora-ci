#!/usr/bin/env python3
# SPDX-License-Identifier: LGPL-2.1+
# systemd-resolve tests

import os
import sys
import unittest
import subprocess

resolv_file='/etc/resolv.conf'
systemd_resolved_conf_file='/etc/systemd/resolved.conf'

class SystemdResolveTests(unittest.TestCase):
    def setUp(self):
        self.set_resolve_conf()
    def tearDown(self):
        pass

    def set_resolve_conf(self):
        resolvers = []
        dns=''

        with open(resolv_file, 'r' ) as resolvconf:
            for line in resolvconf.readlines():
                line = line.split('#', 1)[0];
                line = line.rstrip();
                if 'nameserver' in line:
                    resolvers.append(line.split(' ')[1])

        resolvconf.close()

        for s in resolvers:
            dns += (s + ' ')

        f = open(systemd_resolved_conf_file, "w")
        f.write("[Resolve]\nDNS=%s\nFallbackDNS=8.8.8.8 8.8.4.4 2001:4860:4860::8888 2001:4860:4860::8844\n" % (dns))
        f.close()

    def test_A_and_AAAA(self):

         output = subprocess.check_output(['systemd-resolve', '-4', 'redhat.com']).rstrip().decode('utf-8')
         print(output)

         output = subprocess.check_output(['systemd-resolve', '-4', 'google.com']).rstrip().decode('utf-8')
         print(output)

         output = subprocess.check_output(['systemd-resolve', '-6', 'google.com']).rstrip().decode('utf-8')
         print(output)

    def test_retrieve_domain_of_ip(self):

         output = subprocess.check_output(['systemd-resolve', '85.214.157.71']).rstrip().decode('utf-8')
         print(output)
         self.assertRegex(output, '85.214.157.71')

    def test_retrieve_MX_yahoo(self):

         output = subprocess.check_output(['systemd-resolve', '-t', 'MX' , 'yahoo.com', '--legend=no', 'yahoo.com']).rstrip().decode('utf-8')
         print(output)
         self.assertRegex(output, 'yahoo.com')
         self.assertRegex(output, 'MX')

    def test_retrieve_service(self):

         output = subprocess.check_output(['systemd-resolve', '--service', '_xmpp-server._tcp' , 'gmail.com']).rstrip().decode('utf-8')
         print(output)

    def test_retrieve_via_tls(self):

         output = subprocess.check_output(['systemd-resolve', '--tlsa=tcp', 'fedoraproject.org:443']).rstrip().decode('utf-8')
         print(output)


if __name__ == '__main__':
    unittest.main(testRunner=unittest.TextTestRunner(stream=sys.stdout,
                                                     verbosity=3))
