#!/usr/bin/env bash

set -eu

# https://stackoverflow.com/a/246128
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

ISO_URL="https://mirror.aarnet.edu.au/pub/ubuntu/releases/20.04.1/ubuntu-20.04.1-live-server-amd64.iso"
ISO_NAME="$(basename "${ISO_URL}")"

main() {
  cd "$DIR"

  get_iso

  echo "Done"
}

get_iso() {
  mkdir -p cache

  [ -f "${DIR}/cache/${ISO_NAME}" ] || curl -fL "$ISO_URL" -o "${DIR}/cache/${ISO_NAME}"

  check_iso
}

check_iso() {
  shasum -c "${DIR}/iso.checksums"
}

set -x

main
