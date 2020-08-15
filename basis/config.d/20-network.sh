#!/usr/bin/env bash

set -eu

main() {
  # FIXME: disabled in function
  configure_iwd_for_wifi
  # MANUAL:
  # iwctl station wlan0 connect '<network>'

  update_netplan_config
}

update_netplan_config() {
  local primary_lan_if="enp34s0"

  if [ -f /etc/netplan/00-installer-config.yaml ]; then
    mv /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.bak
  fi

  cat <<EONETPLANCONF > /etc/netplan/50-brlan.yaml
network:
  version: 2
  ethernets:
    ${primary_lan_if}:
      dhcp4: no
      dhcp6: no
  bridges:
    brlan:
      dhcp4: yes
      dhcp6: yes
      interfaces:
        - ${primary_lan_if}
EONETPLANCONF

  netplan apply
  netplan generate
}

configure_iwd_for_wifi() {
  cat <<EOIWDCONF >/etc/iwd/main.conf
[General]
EnableNetworkConfiguration=true
AddressRandomization=once
EOIWDCONF

  # TODO: how can I configure wifi without having routing competition for local subnet?
  systemctl disable iwd
}

set -x

main
