#!/usr/bin/env bash

set -eu

apt_packages=(
  openbox
  xinit

  iwd

  systemd-container
)

main() {
  apt update
  apt upgrade -y
  apt install -y "${apt_packages[@]}"
}

set -x
main
