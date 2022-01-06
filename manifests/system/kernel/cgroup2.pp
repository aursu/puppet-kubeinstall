# @summary Enable Cgroup v2
#
# Enable Cgroup v2 via kernel command line parameters
# https://lwn.net/Articles/671722/
#
# @example
#   include kubeinstall::system::kernel::cgroup2
class kubeinstall::system::kernel::cgroup2 {
  # man cgroups(7)
  #   Because of the problems with the initial cgroups implementation
  #   (cgroups version 1), starting in Linux 3.10, work began on a new,
  #   orthogonal implementation to remedy these problems.  Initially
  #   marked experimental, and hidden behind the
  #   -o __DEVEL__sane_behavior mount option, the new version (cgroups
  #   version 2) was eventually made official with the release of Linux
  #   4.5.
  if versioncmp($facts['kernelversion'], '4.5') >= 0 {
    # temporary solution only for Ubuntu 20.04
    if $facts['os']['name'] == 'Ubuntu' and $facts['os']['release']['major'] == '20.04' {
      file { '/etc/default/grub.d/60-cgroup-v2.cfg':
        ensure  => file,
        content => @(EOF),
                    # Set the commandline
                    GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX systemd.unified_cgroup_hierarchy=1 cgroup_enable=memory swapaccount=1"
                    | - EOF
        owner   => 'root',
        mode    => '0644',
        notify  => Exec['kubeinstall-update-grub'],
      }

      exec { 'kubeinstall-update-grub':
        command     => 'update-grub',
        path        => '/usr/sbin:/usr/bin:/sbin:/bin',
        refreshonly => true,
      }
    }
  }

  # TODO/TOREAD:
  # CHAPTER 26. WORKING WITH GRUB 2
  # https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system_administrators_guide/ch-working_with_the_grub_2_boot_loader
  # CHAPTER 5. CONFIGURING KERNEL COMMAND-LINE PARAMETERS
  # https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/managing_monitoring_and_updating_the_kernel/configuring-kernel-command-line-parameters_managing-monitoring-and-updating-the-kernel
  # CHAPTER 19. USING CGROUPS-V2 TO CONTROL DISTRIBUTION OF CPU TIME FOR APPLICATIONS
  # https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/managing_monitoring_and_updating_the_kernel/using-cgroups-v2-to-control-distribution-of-cpu-time-for-applications_managing-monitoring-and-updating-the-kernel
  # Your kernel does not support cgroup swap limit capabilities
  # https://docs.docker.com/engine/install/linux-postinstall/#your-kernel-does-not-support-cgroup-swap-limit-capabilities
}
