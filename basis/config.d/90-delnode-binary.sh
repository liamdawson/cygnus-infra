#!/usr/bin/env bash

set -eu

main() {
  cat <<'EODELNODEBINARY' > /usr/local/bin/cygnus-delnode
#!/usr/bin/env bash

set -eu

if [ $# -ne 1 ]; then
  echo "usage: $0 <node name>"
  exit 1
fi

virsh destroy "$1" || true
virsh undefine --remove-all-storage "$1"
EODELNODEBINARY
  chmod +x /usr/local/bin/cygnus-delnode
}

set -x

main
