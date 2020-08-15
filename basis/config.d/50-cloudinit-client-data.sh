#!/usr/bin/env bash

set -eu

CLOUDINIT_CONF_DIR="/var/local/lib/cygnus/cloud-init"

main() {
  mkdir -p "$CLOUDINIT_CONF_DIR"

  write_base_userdata "${CLOUDINIT_CONF_DIR}/user-data"
  write_base_metadata "${CLOUDINIT_CONF_DIR}/meta-data"
  enable_config_server
}

write_base_userdata() {
  cat <<EOBASEUSERDATA >"$1"
#cloud-config
users:
  - name: liamdawson
    ssh_import_id: gh:liamdawson
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /usr/bin/bash
apt:
  primary:
    - arches:
        - amd64
        - default
      uri: 'http://au.archive.ubuntu.com/ubuntu'
  sources:
    kubernetes:
      keyid: '6A030B21BA07F4FB'
      keyserver: 'keyserver.ubuntu.com'
      source: 'deb https://apt.kubernetes.io/ kubernetes-xenial main'
    docker:
      keyid: '8D81803C0EBFCD88'
      keyserver: 'keyserver.ubuntu.com'
      source: 'deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable'
package_update: true
package_upgrade: true
packages:
  - qemu-guest-agent
  - nfs-common
  - open-iscsi
  - containerd.io=1.2.13-2
  - docker-ce=5:19.03.11~3-0~ubuntu-focal
  - docker-ce-cli=5:19.03.11~3-0~ubuntu-focal
  - kubeadm
  - kubectl
  - kubelet
# - linux-image-kvm # Cilium eBPF didn't work
write_files:
  - path: /etc/sysctl.d/k8s.conf
    content: |
      net.bridge.bridge-nf-call-ip6tables = 1
      net.bridge.bridge-nf-call-iptables = 1
      net.ipv4.ip_forward = 1
      net.ipv6.conf.all.forwarding = 1
  - path: /etc/docker/daemon.json
    content: |
      {
        "exec-opts": ["native.cgroupdriver=systemd"],
        "log-driver": "json-file",
        "log-opts": {
          "max-size": "100m"
        },
        "storage-driver": "overlay2"
      }
runcmd:
  - [ cloud-init-per, once, hold-kube-pkgs, apt-mark, hold, kubelet, kubeadm, kubectl ]
  - [ cloud-init-per, once, mk-docker-service-dir, mkdir, -p, /etc/systemd/system/docker.service.d ]
power_state:
  mode: reboot
EOBASEUSERDATA
}

write_base_metadata() {
  cat <<EOBASEMETADATA >"$1"
instance_id: cygnus-kube-node-02
EOBASEMETADATA
}

enable_config_server() {
  cat <<EOSERVERUNIT >/etc/systemd/system/cloudinit-data-server.service
[Unit]
Description=Cloud-init data file server

[Service]
User=nobody
Group=nogroup
WorkingDirectory=$CLOUDINIT_CONF_DIR
ExecStart=/usr/bin/python3 -m http.server 5000

[Install]
WantedBy=multi-user.target
EOSERVERUNIT
  systemctl daemon-reload
  systemctl enable cloudinit-data-server
  systemctl restart cloudinit-data-server || systemctl start cloudinit-data-server
}

set -x

main
