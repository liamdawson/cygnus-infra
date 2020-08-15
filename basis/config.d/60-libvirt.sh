#!/usr/bin/env bash

set -e

main() {
  configure_host_pool swan-vg
}

configure_host_pool() {
  if ! virsh pool-info host >/dev/null 2>&1; then
    virsh pool-define-as \
      --name=host \
      --type=logical \
      --source-name="$1" \
      --target="/dev/$1"

    virsh pool-autostart host
    virsh pool-start host
  fi
}

set -x
main
