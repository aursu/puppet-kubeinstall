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

# Check if a command exists
exists() {
  command -v $1 >/dev/null 2>&1
}

# Run command and retry on failure
# run_cmd CMD
run_cmd() {
  info "Executing command: $1"
  eval $1
  local rc=$?

  if test $rc -ne 0; then
    local attempt_number=0
    while test $attempt_number -lt $retry; do
      warn "Command failed with code $rc. Retrying [$((attempt_number + 1))/$retry]..."
      eval $1
      rc=$?
      if test $rc -eq 0; then
        info "Command succeeded on retry $((attempt_number + 1))"
        break
      fi
      sleep 1s
      ((attempt_number=attempt_number+1))
    done
  fi

  if test $rc -ne 0; then
    critical "Command failed after $retry attempts: $1"
  fi

  return $rc
}

# Set retry count (default to 5 if not explicitly passed)
retry=${PT_retry:-5}

# Require root privileges
if [ "$(id -u)" -ne 0 ]; then
  critical "kubeinstall::crio_stop task must be run as root."
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

# Stop kubelet
if systemctl -q --no-pager status kubelet; then
  run_cmd "systemctl stop kubelet"
fi

# Stop containers with crictl
attempt_number=0
while test $attempt_number -lt $retry; do
  c=$(crictl ps -q)
  if [ -z "$c" ]; then
    info "No running containers found. Skipping 'crictl stop'."
    break
  fi
  
  run_cmd "crictl stop $c"

  ((attempt_number=attempt_number+1))
done

# Stop crio
if systemctl -q --no-pager status crio; then
  run_cmd "systemctl stop crio"
fi

info "kubeinstall::crio_stop task completed successfully."
exit 0
