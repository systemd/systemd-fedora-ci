#!/bin/bash
# SPDX-License-Identifier: LGPL-2.1+
# ~~~
#   runtest.sh of unit section
#   Description: Test unit section
#
#   Author: Susant Sahani <susant@redhat.com>
#   Copyright (c) 2018 Red Hat, Inc.
# ~~~

# Include Beaker environment
. /usr/share/beakerlib/beakerlib.sh || exit 1

PACKAGE="systemd"

rlJournalStart
    rlPhaseStartSetup
        rlAssertRpm $PACKAGE
    rlPhaseEnd

    rlPhaseStartTest
        rlLog "Service Test ConditionArchitecture x86-64"

        rlRun "cp condition-architecture-x86-64.service condition-architecture-s390.service condition-architecture-x86.service condition-architecture-aarch64.service condition-architecture-ppc64.service condition-architecture-ppc64le.service /var/run/systemd/system"
	rlRun "cp condition-arch.sh /usr/local/bin/condition-arch.sh"
        rlRun "systemctl daemon-reload"

        rlRun "/usr/local/bin/condition-arch.sh"

        rlRun "rm /var/run/systemd/system/condition-architecture-x86-64.service /var/run/systemd/system/condition-architecture-s390.service /var/run/systemd/system/condition-architecture-x86.service /var/run/systemd/system/condition-architecture-aarch64.service /var/run/systemd/system/condition-architecture-ppc64.service /var/run/systemd/system/condition-architecture-ppc64le.service /usr/local/bin/condition-arch.sh"
     rlPhaseEnd

     rlPhaseStartTest
         rlLog "Service Test ConditionVirtualization"

         rlRun "cp condition-virtualization-none.service condition-virtualization-kvm.service condition-virtualization-qemu.service condition-virtualization-vmware.service condition-virtualization-lxc.service condition-virtualization-lxc-libvirt.service condition-virtualization-systemd-nspawn.service condition-virtualization-docker.service condition-virtualization-rkt.service /var/run/systemd/system"
	 rlRun "cp condition-virtualization.sh /usr/local/bin/condition-virtualization.sh"

         rlRun "systemctl daemon-reload"

         rlRun "/usr/local/bin/condition-virtualization.sh"

         rlRun "rm /var/run/systemd/system/condition-virtualization-none.service /var/run/systemd/system/condition-virtualization-kvm.service /var/run/systemd/system/condition-virtualization-qemu.service /var/run/systemd/system/condition-virtualization-vmware.service /var/run/systemd/system/condition-virtualization-lxc.service /var/run/systemd/system/condition-virtualization-lxc-libvirt.service /var/run/systemd/system/condition-virtualization-systemd-nspawn.service /var/run/systemd/system/condition-virtualization-docker.service /var/run/systemd/system/condition-virtualization-rkt.service /usr/local/bin/condition-virtualization.sh"
         rlRun "systemctl daemon-reload"
     rlPhaseEnd

     rlPhaseStartTest
         rlLog "Service Test ConditionFileIsExecutable"

         rlRun "cp condition-file-is-executable.service /var/run/systemd/system"
         rlRun "systemctl daemon-reload"

         rlRun "install -m 777 /dev/null /run/file-is-executable"

         rlRun "systemctl start condition-file-is-executable.service"
         rlRun -s "systemctl status condition-file-is-executable.service"
         rlAssertGrep "status=0/SUCCES" "$rlRun_LOG"

         rlRun "rm /run/file-is-executable /var/run/systemd/system/condition-file-is-executable.service"
         rlRun "systemctl daemon-reload"

         rlLog "Service Test ConditionFileIsExecutable nonexecutable"

         rlRun "cp condition-file-is-not-executable.service /var/run/systemd/system"
         rlRun "systemctl daemon-reload"

         rlRun "install -m 644 /dev/null /run/file-is-not-executable"

         rlRun "systemctl start condition-file-is-not-executable.service"
         rlRun -s "systemctl status condition-file-is-not-executable.service" 3
         rlAssertNotGrep "status=0/SUCCES" "$rlRun_LOG"

         rlRun "rm /run/file-is-not-executable /var/run/systemd/system/condition-file-is-not-executable.service"
         rlRun "systemctl daemon-reload"
     rlPhaseEnd

     rlPhaseStartTest
         rlLog "Service Test ConditionDirectoryNotEmpty"

         rlRun "cp condition-directory-not-empty.service /var/run/systemd/system"
         rlRun "systemctl daemon-reload"

         rlRun "mkdir /run/condition_directory_not_empty; install -m 644 /dev/null /run/condition_directory_not_empty/file"

         rlRun "systemctl start condition-directory-not-empty.service"
         rlRun -s "systemctl status condition-directory-not-empty.service"
         rlAssertGrep "status=0/SUCCES" "$rlRun_LOG"

         rlRun "rm -rf /run/condition_directory_not_empty /var/run/systemd/system/condition-directory-not-empty.service"
         rlRun "systemctl daemon-reload"

         rlLog "Service Test ConditionDirectoryNotEmpty empty"

         rlRun "cp condition-directory-empty.service /var/run/systemd/system"
         rlRun "systemctl daemon-reload"

         rlRun "mkdir /run/condition_directory_empty"

         rlRun "systemctl start condition-directory-empty.service"
         rlRun -s "systemctl status condition-directory-empty.service" 3
         rlAssertNotGrep "status=0/SUCCES" "$rlRun_LOG"

         rlRun "rm -rf /run/condition_directory_empty /var/run/systemd/system/condition-directory-empty.service"
         rlRun "systemctl daemon-reload"
     rlPhaseEnd

     rlPhaseStartTest
         rlLog "Service ConditionPathIsSymbolicLink"

         rlRun "cp condition-path-is-symbolic-link.service /var/run/systemd/system"
         rlRun "systemctl daemon-reload"

         rlRun "ln -s /dev/null /run/path_is_symbolic_link"

         rlRun "systemctl start condition-path-is-symbolic-link.service"
         rlRun -s "systemctl status condition-path-is-symbolic-link.service"
         rlAssertGrep "status=0/SUCCES" "$rlRun_LOG"

         rlRun "rm -rf /run/path_is_symbolic_link /var/run/systemd/system/condition-path-is-symbolic-link.service"
         rlRun "systemctl daemon-reload"

         rlLog "Service Test ConditionPathIsSymbolicLink (Not)"

         rlRun "cp condition-path-is-not-symbolic-link.service /var/run/systemd/system"
         rlRun "systemctl daemon-reload"

         rlRun "touch /run/path_is_not_symbolic_link"

         rlRun "systemctl start condition-path-is-not-symbolic-link.service"
         rlRun -s "systemctl status condition-path-is-not-symbolic-link.service" 3
         rlAssertNotGrep "status=0/SUCCES" "$rlRun_LOG"

         rlRun "rm /run/path_is_not_symbolic_link /var/run/systemd/system/condition-path-is-not-symbolic-link.service"
         rlRun "systemctl daemon-reload"
     rlPhaseEnd

     rlPhaseStartTest
         rlLog "Service Test OnFailure"

         rlRun "cp on-failure.service on-failure-run.service /var/run/systemd/system"
         rlRun "systemctl daemon-reload"

         rlRun "systemctl start on-failure.service" 1
         rlRun -s "systemctl status on-failure.service" 3
         rlAssertNotGrep "status=0/SUCCES" "$rlRun_LOG"
         rlAssertExists "/run/on-failure-test"

         rlRun "rm /run/on-failure-test /var/run/systemd/system/on-failure.service /var/run/systemd/system/on-failure-run.service"
         rlRun "systemctl daemon-reload"
     rlPhaseEnd

     rlPhaseStartTest
         rlLog "Service Test RefuseManualStart RefuseManualStop"

         rlRun "cp refusal-manual-start-stop.service /var/run/systemd/system"
         rlRun "systemctl daemon-reload"

         rlRun "systemctl start refusal-manual-start-stop.service" 4
         rlRun "systemctl stop refusal-manual-start-stop.service" 4

         rlRun "rm /var/run/systemd/system/refusal-manual-start-stop.service"
         rlRun "systemctl daemon-reload"
     rlPhaseEnd

     rlPhaseStartTest
         rlLog "Service Test assert-architecture"

         rlRun "cp assert-architecture-x86-64.service assert-architecture-x86.service assert-architecture-s390.service assert-architecture-aarch64.service assert-architecture-ppc64.service assert-architecture-ppc64le.service /var/run/systemd/system"
         rlRun "systemctl daemon-reload"

         rlRun "./assert-arch.sh"

         rlRun "rm /var/run/systemd/system/assert-architecture-x86-64.service /var/run/systemd/system/assert-architecture-x86.service /var/run/systemd/system/assert-architecture-s390.service /var/run/systemd/system/assert-architecture-aarch64.service /var/run/systemd/system/assert-architecture-ppc64.service /var/run/systemd/system/assert-architecture-ppc64le.service"
         rlRun "systemctl daemon-reload"
     rlPhaseEnd

     #rlPhaseStartTest
     #rlLog "Service Test AssertVirtualization"

        #rlRun "cp assert-virtualization-docker.service assert-virtualization-none.service assert-virtualization-kvm.service assert-virtualization-lxc.service assert-virtualization-lxc-libvirt.service assert-virtualization-qemu.service assert-virtualization-rkt.service assert-virtualization-vmware.service assert-virtualization-systemd-nspawn.service /var/run/systemd/system"
        #rlRun "systemctl daemon-reload"

        #rlRun "./assert-virtualization.sh"

        #rlRun "rm /var/run/systemd/system/assert-virtualization-docker.service /var/run/systemd/system/assert-virtualization-none.service /var/run/systemd/system/assert-virtualization-kvm.service /var/run/systemd/system/assert-virtualization-lxc.service /var/run/systemd/system/assert-virtualization-lxc-libvirt.service /var/run/systemd/system/assert-virtualization-qemu.service /var/run/systemd/system/assert-virtualization-rkt.service /var/run/systemd/system/assert-virtualization-vmware.service /var/run/systemd/system/assert-virtualization-systemd-nspawn.service"
        #rlRun "systemctl daemon-reload"
     #rlPhaseEnd

     rlPhaseStartTest
         rlLog "Service Test AssertFileIsExecutable"

         rlRun "cp assert-file-is-executable.service /var/run/systemd/system"
         rlRun "systemctl daemon-reload"

         rlRun "install -m 777 /dev/null /run/test-assert-file-is-executable"

         rlRun "systemctl start assert-file-is-executable.service"
         rlRun -s "systemctl status assert-file-is-executable.service"
         rlAssertGrep "status=0/SUCCES" "$rlRun_LOG"

         rlRun "rm /run/test-assert-file-is-executable /var/run/systemd/system/assert-file-is-executable.service"
         rlRun "systemctl daemon-reload"

         rlLog "Service Test ConditionFileIsExecutable nonexecutable"

         rlRun "cp assert-file-is-not-executable.service /var/run/systemd/system"
         rlRun "systemctl daemon-reload"

         rlRun "install -m 644 /dev/null /run/file-is-not-executable"

         rlRun "systemctl start assert-file-is-not-executable.service" 1

         rlRun "rm /run/file-is-not-executable /var/run/systemd/system/assert-file-is-not-executable.service"
         rlRun "systemctl daemon-reload"
     rlPhaseEnd

     rlPhaseStartTest
         rlLog "Service Test AssertFileNotEmpty"

         rlRun "cp assert_file_not_empty.service /var/run/systemd/system"
         rlRun "systemctl daemon-reload"

         rlRun "echo \"some file content\" > /run/assert-file-is-not-empty "

         rlRun "systemctl start assert_file_not_empty.service"

         rlRun "rm /run/assert-file-is-not-empty /var/run/systemd/system/assert_file_not_empty.service"
         rlRun "systemctl daemon-reload"

         rlLog "Service Test AssertFileNotEmpty empty"

         rlRun "cp assert_file_is_empty.service /var/run/systemd/system"
         rlRun "systemctl daemon-reload"

         rlRun " install -m 644 /dev/null /run/assert-file-is-empty"

         rlRun "systemctl start assert_file_is_empty.service" 1

         rlRun "rm /run/assert-file-is-empty /var/run/systemd/system/assert_file_is_empty.service"
         rlRun "systemctl daemon-reload"
     rlPhaseEnd

     rlPhaseStartTest
         rlLog "Service Test AssertDirectoryNotEmpty"

         rlRun "cp assert_directory_not_empty.service /var/run/systemd/system"
         rlRun "systemctl daemon-reload"

         rlRun "mkdir /run/assert_directory_not_empty; install -m 644 /dev/null /run/assert_directory_not_empty/file "

         rlRun "systemctl start assert_directory_not_empty.service"

         rlRun "rm -rf /run/assert_directory_not_empty /var/run/systemd/system/assert_directory_not_empty.service"
         rlRun "systemctl daemon-reload"

         rlLog "Service Test AssertDirectoryNotEmpty empty"

         rlRun "cp assert_directory_is_empty.service /var/run/systemd/system"
         rlRun "systemctl daemon-reload"

         rlRun "mkdir /run/assert_directory_is_empty"

         rlRun "systemctl start assert_directory_is_empty.service" 1

         rlRun "rm -rf /run/assert_directory_is_empty /var/run/systemd/system/assert_directory_is_empty.service"
         rlRun "systemctl daemon-reload"
     rlPhaseEnd

     rlPhaseStartTest
         rlLog "Service Test AssertPathIsSymbolicLink"

         rlRun "cp assert_directory_not_empty.service /var/run/systemd/system"
         rlRun "systemctl daemon-reload"

         rlRun "ln -s /dev/null /run/path_is_symbolic_link"

         rlRun "systemctl start assert_directory_not_empty.service"

         rlRun "rm /run/path_is_symbolic_link /var/run/systemd/system/assert_directory_not_empty.service"
         rlRun "systemctl daemon-reload"

         rlLog "Service Test AssertPathIsSymbolicLink empty"

         rlRun "cp assert_file_is_empty.service /var/run/systemd/system"
         rlRun "systemctl daemon-reload"

         rlRun "touch /run/path_is_not_symbolic_link"

         rlRun "systemctl start assert_file_is_empty.service" 1

         rlRun "rm -rf /run/assert_directory_is_empty /var/run/systemd/system/assert_file_is_empty.service"
         rlRun "systemctl daemon-reload"
     rlPhaseEnd

     rlPhaseStartTest
         rlLog "Service Test AssertPathIsDirectory"

         rlRun "cp assert_path_is_directory.service /var/run/systemd/system"
         rlRun "systemctl daemon-reload"

         rlRun "mkdir /run/assert_path_is_directory"

         rlRun "systemctl start assert_path_is_directory.service"

         rlRun "rm -rf /run/assert_path_is_directory /var/run/systemd/system/assert_path_is_directory.service"
         rlRun "systemctl daemon-reload"

         rlLog "Service Test AssertPathIsDirectory"

         rlRun "cp assert_path_is_not_directory.service /var/run/systemd/system"
         rlRun "systemctl daemon-reload"

         rlRun "install -m 644 /dev/null /run/assert_path_is_not_directory"

         rlRun "systemctl start assert_path_is_not_directory.service" 1

         rlRun "rm -rf /run/assert_path_is_not_directory /var/run/systemd/system/assert_path_is_not_directory.service"
         rlRun "systemctl daemon-reload"
     rlPhaseEnd

     rlPhaseStartTest
         rlLog "Service Test AssertPathExists"

         rlRun "cp assert_path_exists.service /var/run/systemd/system"
         rlRun "systemctl daemon-reload"

         rlRun "mkdir /run/assert_path_exists"

         rlRun "systemctl start assert_path_exists.service"

         rlRun "rm -rf /run/assert_path_exists /var/run/systemd/system/assert_path_exists.service"
         rlRun "systemctl daemon-reload"

         rlLog "Service Test AssertPathExists"

         rlRun "cp assert_path_not_exists.service /var/run/systemd/system"
         rlRun "systemctl daemon-reload"

         rlRun "systemctl start assert_path_not_exists.service" 1

         rlRun "rm /var/run/systemd/system/assert_path_not_exists.service"
         rlRun "systemctl daemon-reload"
     rlPhaseEnd

     rlPhaseStartCleanup
         rlRun "systemctl daemon-reload"
    rlPhaseEnd
rlJournalPrintText
rlJournalEnd

rlGetTestState
