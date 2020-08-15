#!/usr/bin/env bash

set -eu

apt_packages=(
  openbox
  xinit

  iwd

  nfs-common

  systemd-container

  libosinfo-bin
  virtinst
  qemu-kvm
  libvirt-daemon-system
)

main() {
  apt update
  apt upgrade -y
  apt install -y "${apt_packages[@]}"
}

set -x
main
