#!/usr/bin/env bash

set -e

main() {
  configure_exports

  exportfs -a
}

# directories should be 777/nobody:nogroup
configure_exports() {
  cat <<EOEXPORTS > /etc/exports
# /etc/exports: the access control list for filesystems which may be exported
# to NFS clients.  See exports(5).

/srv/cygnus/state 192.168.1.0/20(sync,rw,all_squash,insecure)
EOEXPORTS
}

set -x
main
