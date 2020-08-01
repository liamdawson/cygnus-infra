#!/usr/bin/env bash

set -eu

apt_packages=(
  cpu-checker
  bridge-utils
  unattended-upgrades
  vim
  apt-transport-https
  ca-certificates
  curl
  gnupg-agent
  software-properties-common
)

main() {
  primary_device_name="$(get_primary_device_name)"
  apt-get install -y "${apt_packages[@]}"

  cat <<EOIFACES > /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# primary LAN interface
auto ${primary_device_name}
allow-hotplug ${primary_device_name}
iface ${primary_device_name} inet manual

# host bridge, connecting to untagged LAN
auto br0
iface br0 inet dhcp
  bridge_hw ${br0_mac}
  bridge-ports ${primary_device_name}
  metric 100

# kubernetes node bridge, tagged for VLAN
auto br1
iface br1 inet dhcp
  bridge_hw ${br1_mac}
  bridge-ports ${primary_device_name}.587
  metric 2000
EOIFACES
}

vagrant_workarounds() {
  if ! $is_in_vagrant; then
    return 0
  fi

  cat <<EOVDEV >> /etc/network/interfaces

# vagrant assumes eth0 is configured
allow-hotplug eth0
auto eth0
iface eth0 inet dhcp
metric 500
EOVDEV
}

get_primary_device_name() {
  if [ -d /vagrant ]; then
    echo "eth1"
  else
    # I tried the ip route get 1 approach, but that isn't idempotent
    # The VLAN'd version appears if "." isn't excluded
    basename "$(find /sys/class/net -iregex '/sys/class/net/enp[^.]+' | head -n1)"
  fi
}

primary_device_name="$(get_primary_device_name)"
is_in_vagrant="false"

if [ -d /vagrant ]; then
  is_in_vagrant="true"
  primary_device_name="eth1"
fi

primary_mac="$(cat "/sys/class/net/${primary_device_name}/address")"
br0_mac="$(echo "${primary_mac}-br0" | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02:\1:\2:\3:\4:\5/')"
br1_mac="$(echo "${primary_mac}-br1" | md5sum | sed 's/^\(..\)\(..\)\(..\)\(..\)\(..\).*$/02:\1:\2:\3:\4:\5/')"

set -x
main
vagrant_workarounds
