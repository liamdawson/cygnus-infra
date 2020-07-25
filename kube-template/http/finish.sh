#!/usr/bin/env sh

set -eux

# removed later by packer
echo 'ubuntu ALL=(ALL:ALL) NOPASSWD: ALL' > /etc/sudoers.d/ubuntu

# grub tty0/ttyS0 config
sed -iEe 's/GRUB_CMDLINE_LINUX=".*"/GRUB_CMDLINE_LINUX="console=tty0 console=ttyS0,115200"/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# remove cdrom entry
sed -i "/^deb cdrom:/s/^/#/" /etc/apt/sources.list

# docker/kubernetes repositories
curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
add-apt-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main"

# versions from kubernetes install instructions for v1.18
apt-get update -y && apt-get install -y \
  containerd.io=1.2.13-2 \
  docker-ce=5:19.03.11~3-0~debian-buster \
  docker-ce-cli=5:19.03.11~3-0~debian-buster \
  kubeadm \
  kubectl \
  kubelet

apt-mark hold kubelet kubeadm kubectl

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
EOF

mkdir -p /etc/systemd/system/docker.service.d
mkdir -p /etc/docker
cat > /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

apt-get install -y --install-recommends cloud-init cloud-guest-utils

# ref: https://salsa.debian.org/cloud-team/debian-cloud-images/-/blob/bc0d6f4c9062580dd085c8612fb42c521de2e04f/config_space/files/etc/cloud/cloud.cfg.d/01_debian_cloud.cfg/EC2
cat > /etc/cloud/cloud.cfg.d/10_user.cfg <<EOF
system_info:
  default_user:
    name: debian
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: False
    gecos: Debian
    groups: [adm, audio, cdrom, dialout, dip, floppy, netdev, plugdev, sudo, video]
EOF
