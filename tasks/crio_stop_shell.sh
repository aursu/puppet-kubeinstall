#!/usr/bin/env bash

# Timestamp
now () {
    date +'%H:%M:%S %z'
}

# Logging functions instead of echo
log () {
    echo "$(now) ${1}"
}

info () {
    log "INFO: ${1}"
}

warn () {
    log "WARN: ${1}"
}

critical () {
    log "CRIT: ${1}"
}

# Check whether a command exists - returns 0 if it does, 1 if it does not
exists() {
  if command -v $1 >/dev/null 2>&1
  then
    return 0
  else
    return 1
  fi
}

# Run command and retry on failure
# run_cmd CMD
run_cmd() {
  eval $1
  local rc=$?

  if test $rc -ne 0; then
    local attempt_number=0
    while test $attempt_number -lt $retry; do
      info "Retrying... [$((attempt_number + 1))/$retry]"
      eval $1
      rc=$?

      if test $rc -eq 0; then
        break
      fi

      info "Return code: $rc"
      sleep 1s
      ((attempt_number=attempt_number+1))
    done
  fi

  return $rc
}

if [ -n "$PT_retry" ]; then
  retry=$PT_retry
else
  retry=5
fi

# Error if non-root
if [ $(id -u) -ne 0 ]; then
  echo "kubeinstall::crio_stop task must be run as root"
  exit 1
fi

if ! exists systemctl >/dev/null 2>&1; then
  critical "kubeinstall::crio_stop task requires 'systemctl' to manage systemd services. This system is not supported."
  exit 1
fi


if ! exists crictl >/dev/null 2>&1; then
  critical "kubeinstall::crio_stop task requires 'crictl' to manage container runtimes. This system is not supported."
  exit 1
fi

# systemctl stop kubelet
if systemctl -q --no-pager status kubelet; then
  run_cmd "systemctl stop kubelet"
fi

attempt_number=0
while test $attempt_number -lt $retry; do

  # refresh stats
  c=$(crictl ps -q)

  # check either any job to do available
  [ -z "$c" ] && break
  
  crictl stop $c

  # counter
  ((attempt_number=attempt_number+1))
done

# systemctl stop crio
if systemctl -q --no-pager status crio; then
  run_cmd "systemctl stop crio"
fi
