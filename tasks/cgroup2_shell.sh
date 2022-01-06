#!/usr/bin/env bash

# Error if non-root
if [ $(id -u) -ne 0 ]; then
  echo "kubeinstall::cgroup2 task must be run as root"
  exit 1
fi

function now {
  date +'%H:%M:%S %z'
}

function log {
  echo "$(now) ${1}"
}

function info {
  log "INFO: ${1}"
}

function critical {
  log "CRIT: ${1}"
}

# bash 4.3+: usage: sort_array_43 arr_name
function sort_array_43 {
  local -n sorted=$1

  IFS=$'\n'; sorted=($(sort <<< "${sorted[*]}")); unset IFS
}

# bash 4.2-: usage: arr_name=($(sort_array_42 ${arr_name[@]}))
function sort_array_42 {
  local unsorted=( "$@" )

  IFS=$'\n'; sort <<< "${unsorted[*]}"; unset IFS
}

# input is array of kernel parameters either from /etc/default/grub
# or from /proc/cmdline
# return 0 if parameters for cgroup v2 already set
# otherwise - returns 1
function check_existing {
  local cmdline=( "$@" )

  local existing=()

  for parameter in "${cmdline[@]}"; do
    if echo $parameter | grep -q "\(systemd.unified_cgroup_hierarchy\|cgroup_enable\|swapaccount\)="; then
      existing+=($parameter)
    fi
  done

  # sort array of existing options and check it with desired state
  existing=($(sort_array_42 "${existing[@]}"))
  if [ "${existing[*]}" = "cgroup_enable=memory swapaccount=1 systemd.unified_cgroup_hierarchy=1" ]; then
    return 0
  fi

  return 1
}

function setup_default_grub {
  local GRUB_CMDLINE_LINUX_NEW="systemd.unified_cgroup_hierarchy=1 cgroup_enable=memory swapaccount=1"

  [ -f /etc/default/grub ] || {
    info "Grub2 configuration file /etc/default/grub not found"
    return 1
  }

  . /etc/default/grub

  check_existing $GRUB_CMDLINE_LINUX && {
    info "All required kernel parameters already set in /etc/default/grub (GRUB_CMDLINE_LINUX=$GRUB_CMDLINE_LINUX)"
    return 1
  }

  for parameter in $GRUB_CMDLINE_LINUX; do
    if echo $parameter | grep -q "\(systemd.unified_cgroup_hierarchy\|cgroup_enable\|swapaccount\)="; then
      continue
    fi
    GRUB_CMDLINE_LINUX_NEW="$GRUB_CMDLINE_LINUX_NEW $parameter"
  done

  # replace GRUB_CMDLINE_LINUX in /etc/default/grub
  info "Set kernel parameters to $GRUB_CMDLINE_LINUX_NEW"

  sed -i '/^GRUB_CMDLINE_LINUX=/d' /etc/default/grub
  echo "GRUB_CMDLINE_LINUX=\"$GRUB_CMDLINE_LINUX_NEW\"" >> /etc/default/grub

  return 0
}

kernel_release=$(uname -r)
kernel_version=${kernel_release%%-*}
kernel_maj=${kernel_version%%.*}
_kernel_min_patch=${kernel_version#*.}
kernel_min=${_kernel_min_patch%%.*}

if [ $kernel_maj -eq 4 -a $kernel_min -ge 5 ] || [ $kernel_maj -ge 5 ]; then
  :
else
  critical "Kernel ${kernel_release} does not support cgroups version 2"
  exit 1
fi

# Retrieve Platform and Platform Version
# Utilize facts implementation when available
if [ -f "$PT__installdir/facts/tasks/bash.sh" ]; then
  # Use facts module bash.sh implementation
  platform=$(bash $PT__installdir/facts/tasks/bash.sh "platform")
  platform_version=$(bash $PT__installdir/facts/tasks/bash.sh "release")
  major_version=$(echo $platform_version | cut -d. -f1)
else
  critical "This module depends on the puppetlabs-facts module"
  exit 1
fi

if test "x$platform" = "x"; then
  critical "Unable to determine platform version!"
  exit 1
fi

message=
grub_updated="null"
case $platform in
  "CentOS")
    case $major_version in
      "7")
        # reconfigure grub
        message=$(setup_default_grub) && {
          if [ -e /usr/sbin/grub2-mkconfig ]; then
            if [ -f /boot/grub2/grub.cfg ]; then
              grub_updated="true"
              /usr/sbin/grub2-mkconfig -o /boot/grub2/grub.cfg
            elif [ -f /boot/efi/EFI/redhat/grub.cfg ]; then
              grub_updated="true"
              /usr/sbin/grub2-mkconfig -o /boot/efi/EFI/redhat/grub.cfg
            fi
          fi
        }
        ;;
      *)
        critical "CentOS $major_version is not supported yet!"
        exit 1
        ;;
    esac
    ;;
  "Ubuntu")
    case $platform_version in
      "20.04")
        # reconfigure grub
        message=$(setup_default_grub) && {
          grub_updated="true"
          /usr/sbin/update-grub
        }
        ;;
      *)
        critical "Ubuntu $platform_version is not supported yet!"
        exit 1
        ;;
    esac
    ;;
  *)
    critical "$platform is not supported yet!"
    exit 1
    ;;
esac

if check_existing $(cat /proc/cmdline); then
  echo "{\"platform\":\"$platform\",\"platform_version\":\"$platform_version\",\"reboot\":false,\"parameters\":\"$(cat /proc/cmdline)\",\"grub_updated\":$grub_updated,\"message\":\"$message\"}"
else
  echo "{\"platform\":\"$platform\",\"platform_version\":\"$platform_version\",\"reboot\":true,\"parameters\":\"$(cat /proc/cmdline)\",\"grub_updated\":$grub_updated,\"message\":\"$message\"}"
fi

exit 0
