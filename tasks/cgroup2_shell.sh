#!/usr/bin/env bash

# Error if non-root
if [ $(id -u) -ne 0 ]; then
  echo "puppet::cgroup2 task must be run as root"
  exit 1
fi

log () {
  echo "$(now) ${1}"
}

info () {
  log "INFO: ${1}"
}

critical () {
    log "CRIT: ${1}"
}

setup_default_grub() {
  . /etc/default/grub

  GRUB_CMDLINE_LINUX_NEW=
  for parameter in $GRUB_CMDLINE_LINUX; do
    case "${parameter%%=*}" in
    "systemd.unified_cgroup_hierarchy")
      GRUB_CMDLINE_LINUX_NEW="$GRUB_CMDLINE_LINUX_NEW systemd.unified_cgroup_hierarchy=1"
      ;;
    "cgroup_enable")
      GRUB_CMDLINE_LINUX_NEW="$GRUB_CMDLINE_LINUX_NEW cgroup_enable=memory"
      ;;
    "swapaccount")
      GRUB_CMDLINE_LINUX_NEW="$GRUB_CMDLINE_LINUX_NEW swapaccount=1"
      ;;
    *)
      GRUB_CMDLINE_LINUX_NEW="$GRUB_CMDLINE_LINUX_NEW $parameter"
      ;;
    esac
  done

  # replace GRUB_CMDLINE_LINUX in /etc/default/grub
  sed -i '/^GRUB_CMDLINE_LINUX=/d' /etc/default/grub
  echo "GRUB_CMDLINE_LINUX=\"$GRUB_CMDLINE_LINUX_NEW\"" >> /etc/default/grub
}

# Retrieve Platform and Platform Version
# Utilize facts implementation when available
if [ -f "$PT__installdir/facts/tasks/bash.sh" ]; then
  # Use facts module bash.sh implementation
  platform=$(bash $PT__installdir/facts/tasks/bash.sh "platform")
  platform_version=$(bash $PT__installdir/facts/tasks/bash.sh "release")
  major_version=$(echo $platform_version | cut -d. -f1)
else
  echo "This module depends on the puppetlabs-facts module"
  exit 1
fi

if test "x$platform" = "x"; then
  critical "Unable to determine platform version!"
  exit 1
fi

info "Enable cgroups version 2 for ${platform}..."
case $platform in
  "CentOS")
    info "CentOS platform! Lets enable cgroups version 2..."
    case $major_version in
      "7")
        setup_default_grub

        # reconfigure grub
        if [ -e /usr/sbin/grub2-mkconfig ]; then
          if [ -f /boot/grub2/grub.cfg ]; then
            /usr/sbin/grub2-mkconfig -o /boot/grub2/grub.cfg
          elif [ -f /boot/efi/EFI/redhat/grub.cfg ]; then
            /usr/sbin/grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
          fi
        fi
        ;;
      *)
        critical "Sorry CentOS $major_version is not supported yet!"
        exit 1
        ;;
    esac
    ;;
  "Ubuntu")
    info "Ubuntu platform! Lets enable cgroups version 2..."
    case $platform_version in
      "20.04")
        setup_default_grub

        # reconfigure grub
        /usr/sbin/update-grub
        ;;
      *)
        critical "Sorry Ubuntu $platform_version is not supported yet!"
        exit 1
        ;;
    esac
    ;;
  *)
    critical "Sorry $platform is not supported yet!"
    exit 1
    ;;
esac
