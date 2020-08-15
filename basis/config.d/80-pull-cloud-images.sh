#!/usr/bin/env bash

set -eu

main() {
  pull_ubuntu_cloud_image
}

pull_ubuntu_cloud_image() {
  IMG_URL="https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img"
  IMG_NAME="focal-server-cloudimg-amd64"

  if ! machinectl show-image "$IMG_NAME" >/dev/null; then
    machinectl pull-raw --verify=checksum "$IMG_URL"
  fi
}

set -x

main
