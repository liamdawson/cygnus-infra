#!/usr/bin/env bash

set -eu

main() {
  configure_iwd_for_wifi
  # iwctl station wlan0 connect '<network>'
  setup_lan_bridge
  apply_network
  disable_netplan
  # TODO: how can I configure wifi without having routing competition for local subnet?
  systemctl disable iwd
}

setup_lan_bridge() {
  cat <<EOCABLE >/etc/systemd/network/cable.network
[Match]
Name=enp34s0

[Network]
Bridge=brlan
DHCP=no
EOCABLE

  cat <<EOLANBRIDGEDEV >/etc/systemd/network/brlan.netdev
[NetDev]
Name=brlan
Kind=bridge
EOLANBRIDGEDEV

  cat <<EOLANBRIDGENET >/etc/systemd/network/brlan.network
[Match]
Name=brlan

[Network]
DHCP=yes

[DHCP]
RouteMetric=100

[Route]
Destination=192.168.0.0/20
Metric=100
EOLANBRIDGENET
}

configure_iwd_for_wifi() {
  cat <<EOIWDCONF >/etc/iwd/main.conf
[General]
EnableNetworkConfiguration=true
AddressRandomization=once
EOIWDCONF
}

apply_network() {
  systemctl daemon-reload && systemctl enable --now systemd-networkd
}

disable_netplan() {
  if [ -f /etc/netplan/00-installer-config.yaml ]; then
    mv /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak
  fi
}

set -x

main
